import { google } from "googleapis";
import { GoogleAuth } from "google-auth-library";
import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { _getUserData, Purchase } from "./user_manager";
import { verifyAppCheckToken } from "./verify_app_check";

const auth = new GoogleAuth({
  keyFile: "./photo-enhancer-app-playdeveloper-key.json",
  scopes: ["https://www.googleapis.com/auth/androidpublisher"],
});

const playDeveloperApi = google.androidpublisher("v3");

interface ChargeCreditsRequest {
  userId: string,
  purchaseToken: string,
  productId: string,
  packageName: string,
}


/**
*
* @function verifyGooglePlayPurchase
* @param {string} purchaseToken
* @param {string} productId
* @param {string} packageName
* @returns {Promise<boolean>}
*
* **📌 Request Requirements**
* - **purchaseToken:** The unique token provided by Google Play for the purchase.
* - **productId:** The product ID of the item being purchased.
* - **packageName:** The package name of the app making the request.
*
* **✅ Successful Response**
* - If the purchase is valid, the function returns `true` indicating that the purchase is successful
*   and the user is entitled to the credits.
*
* **⚠️ Failure Responses**
*
* ! Invalid purchase (Google Play API verification fails)
* ```json
* {
*   "error": "Purchase verification failed"
* }
* ```
*
* **📝 Notes**
* - This function verifies the purchase status with the Google Play Developer API.
* - It checks whether the purchase is valid (state `0` means purchased).
* - The function returns `false` if the verification fails, indicating the purchase is not valid.
*/

async function verifyGooglePlayPurchase(
  purchaseToken: string,
  productId: string,
  packageName: string): Promise<boolean> {
  try {
    google.options({ auth: auth });

    const response = await playDeveloperApi.purchases.products.get({
      packageName,
      productId,
      token: purchaseToken,
    });

    return response.data.purchaseState === 0; // 0 = Purchased
  } catch (error) {
    console.error("Purchase verification failed:", error);
    return false;
  }
}


/**
*
* @function chargeCredits
* @param {Request} req
* @param {Response} res
* @returns {Promise<any>}
*
* **📌 Request Requirements**
* - **Method:** `POST`
* - **Headers:**
*   - `"X-Firebase-AppCheck": "<VALID_APP_CHECK_TOKEN>"`
* - **Body (JSON):**
*   {
*     "userId": "USER_ID",
*     "purchaseToken": "PURCHASE_TOKEN",
*     "productId": "PRODUCT_ID",
*     "packageName": "PACKAGE_NAME"
*   }
*
* **✅ Successful Response**
* ```json
* {
*   "success": true,
*   "newCredit": 30
* }
* ```
* - The response indicates that the purchase was successful and the user's credits were updated.
*
* **⚠️ Failure Responses**
*
* ! Missing required fields in the request body
* ```json
* {
*   "error": "Missing required fields"
* }
* ```
*
* ! Duplicate purchase detected (purchaseToken already used)
* ```json
* {
*   "success": false,
*   "error": "Duplicate purchase detected"
* }
* ```
*
* ! Invalid purchase (Google Play verification failed)
* ```json
* {
*   "error": "Invalid purchase"
* }
* ```
*
* ! Internal server error
* ```json
* {
*   "error": "Failed to process purchase"
* }
* ```
*
* **📝 Notes**
* - This function verifies the purchase with Google Play, then adds the corresponding credits to the user's account.
* - If the purchase has already been processed (i.e., a duplicate purchase), it returns a failure response.
* - If the purchase is valid, the function updates the user's credit and logs the purchase details in Firestore.
*/

export const chargeCredits = onRequest(async (req, res): Promise<any> => {
  try {
    // Verify the App Check token
    await verifyAppCheckToken(req, res);

    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method Not Allowed" });
    }

    const { userId, purchaseToken, productId, packageName }: ChargeCreditsRequest = req.body;

    if (!userId || !purchaseToken || !productId || !packageName) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Get user data
    const { userRef, userData } = await _getUserData(userId);

    const previousPurchases: Purchase[] = userData?.purchases || [];

    // Check if this purchaseToken already exists (to prevent duplicate credit updates)
    if (previousPurchases.some((p: any) => p.purchaseToken === purchaseToken)) {
      return res.status(200).json({ success: false, error: "Duplicate purchase detected" });
    }

    //  Verify purchase with Google Play API
    const isValid = await verifyGooglePlayPurchase(purchaseToken, productId, packageName);
    if (!isValid) {
      return res.status(400).json({ error: "Invalid purchase" });
    }

    // Define credit values based on productId
    const creditMap: Record<string, number> = {
      "credit_package_10": 10,
      "credit_package_20": 20,
    };
    const creditAmount = creditMap[productId] || 0;

    // Update user's credits & save purchase details
    await userRef.update({
      credit: admin.firestore.FieldValue.increment(creditAmount),
      purchases: admin.firestore.FieldValue.arrayUnion({
        purchaseToken,
        productId,
        amount: creditAmount,
        timestamp: admin.firestore.Timestamp.now(),
      }),
    });

    return res.json({ success: true, newCredit: (userData?.credit || 0) + creditAmount });
  } catch (error) {
    console.error("Error processing purchase:", error);
    return res.status(500).json({ error: "Failed to process purchase" });
  }
});

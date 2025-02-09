import { google } from "googleapis";
import { GoogleAuth } from "google-auth-library";
import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

interface ChargeCreditsRequest{
    userId:string,
    purchaseToken:string,
    productId:string,
    packageName:string,
}

interface Purchase {
    productId: string;
    purchaseToken: string;
    purchaseTime: number;
}

const db = admin.firestore();

const auth = new GoogleAuth({
    keyFile: "./photo-enhancer-app-playdeveloper-key.json",  
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
});

const playDeveloperApi = google.androidpublisher("v3");

async function verifyGooglePlayPurchase(purchaseToken: string, productId: string,packageName: string) {
    try { 
        google.options({ auth: auth });

        const response = await playDeveloperApi.purchases.products.get({
            packageName,
            productId,
            token: purchaseToken
        });

        return response.data.purchaseState === 0; // 0 = Purchased
    } catch (error) {
        console.error("Purchase verification failed:", error);
        return false;
    }
}

 
export const chargeCredits = onRequest(async (req, res): Promise<any> => {
    try {
        if (req.method !== "POST") {
            return res.status(405).json({ error: "Method Not Allowed" });
        }

        const { userId, purchaseToken, productId,packageName } : ChargeCreditsRequest = req.body;

        if (!userId || !purchaseToken || !productId || !packageName) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        // Get the user's document
        const userRef = db.collection("users").doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            return res.status(404).json({ error: "User not found" });
        }

        const userData = userDoc.data();

        if(!userData){
            return res.status(404).json({ error: "User data not found: " + userDoc.id});
        }

        const previousPurchases: Purchase[] = userData!.purchases || [];

        // Check if this purchaseToken already exists (to prevent duplicate credit updates)
        if (previousPurchases.some((p: any) => p.purchaseToken === purchaseToken)) {
            return res.status(200).json({ success: false, error: "Duplicate purchase detected" });
        }

        //  Verify purchase with Google Play API
        const isValid = await verifyGooglePlayPurchase(purchaseToken, productId,packageName);
        if (!isValid) {
            return res.status(400).json({ error: "Invalid purchase" });
        }

        // Define credit values based on productId
        const creditMap: Record<string, number> = {
            "credit_package_10": 10,
            "credit_package_20": 20
        };
        const creditAmount = creditMap[productId] || 0;

        // Update user's credits & save purchase details
        await userRef.update({
            credit: admin.firestore.FieldValue.increment(creditAmount),
            purchases: admin.firestore.FieldValue.arrayUnion({
                purchaseToken,
                productId,
                amount: creditAmount,
                timestamp: admin.firestore.Timestamp.now()
            })
        });

        return res.json({ success: true, newCredit: (userData.credit || 0) + creditAmount });

    } catch (error) {
        console.error("Error processing purchase:", error);
        return res.status(500).json({ error: "Failed to process purchase" });
    }
});
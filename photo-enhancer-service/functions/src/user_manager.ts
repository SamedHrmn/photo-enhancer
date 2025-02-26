
import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import { getDownloadURL } from "firebase-admin/storage";
import { applicationDefault } from "firebase-admin/app";
import * as logger from "firebase-functions/logger";
import { verifyAppCheckToken } from "./verify_app_check";
import * as fs from "fs";
import * as path from "path";
import { Storage } from '@google-cloud/storage';

interface CreateUserRequest {
    googleId: string;
    androidId: string;
}

interface CreateUserResponse {
    success: boolean;
    message: string;
    data: UserData | null;
    error: {
        code: string | null;
        details: string | null;
    } | null;

}

export interface UserData {
    googleId: string;
    androidId: string;
    credit: number;
    purchases: Purchase[];
}

export interface Purchase {
    productId: string;
    purchaseToken: string;
    purchaseTime: number;
}

admin.initializeApp({
    credential: applicationDefault(),
    storageBucket: "photo-enhancer-app-7022025.firebasestorage.app",
});

const db = getFirestore();
// const bucket = admin.storage().bucket();


const storage = new Storage({
    projectId: 'photo-enhancer-app-7022025',
    keyFilename: './photo-enhancer-app-7022025-firebase-adminsdk-fbsvc-060bc396fd.json',
});

const bucket = storage.bucket("photo-enhancer-app-7022025.firebasestorage.app");


/**
*
* @function createUser
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
*     "googleId": "USER_GOOGLE_ID",
*     "androidId": "USER_ANDROID_ID"
*   }
*
* **✅ Successful Response**
* ```json
* {
*   "success": true,
*   "message": "User created successfully",
*   "data": {
*     "googleId": "USER_GOOGLE_ID",
*     "androidId": "USER_ANDROID_ID",
*     "credit": 10,
*     "purchases": []
*   },
*   "error": null
* }
* ```
*
* **⚠️ Failure Responses**
*
* ! Missing or invalid request method
* ```json
* {
*   "success": false,
*   "error": {
*     "code": "405",
*     "details": "Method not allowed"
*   }
* }
* ```
*
* ! Missing googleId or androidId in request body
* ```json
* {
*   "success": false,
*   "error": {
*     "code": "400",
*     "details": "Missing googleId or androidId"
*   }
* }
* ```
*
* ! User with the same googleId already exists
* ```json
* {
*   "success": true,
*   "message": "User already exist.",
*   "data": {
*     "googleId": "USER_GOOGLE_ID",
*     "androidId": "USER_ANDROID_ID",
*     "credit": 10,
*     "purchases": []
*   },
*   "error": null
* }
* ```
*
* ! Device already used by another user (same androidId)
* ```json
* {
*   "success": true,
*   "message": "User created with 0 credits. Device already used.",
*   "data": {
*     "googleId": "USER_GOOGLE_ID",
*     "androidId": "USER_ANDROID_ID",
*     "credit": 0,
*     "purchases": []
*   },
*   "error": null
* }
* ```
*
* ! Internal server error
* ```json
* {
*   "success": false,
*   "error": {
*     "code": "500",
*     "details": "Failed to create user"
*   }
* }
* ```
*/


export const createUser = onRequest(async (req, res): Promise<any> => {
    try {
        // Verify the App Check token
        await verifyAppCheckToken(req, res);

        if (req.method !== "POST") {
            logger.error("Method Not Allowed");
            return res.status(405).json({
                success: false,
                error: { code: "405", details: "Method not allowed" },
            } as CreateUserResponse);
        }

        const { googleId, androidId }: CreateUserRequest = req.body;

        if (!googleId || !androidId) {
            logger.error("Missing googleId or androidId");
            return res.status(400).json({
                success: false, error:
                    { code: "400", details: "Missing googleId or androidId" },
            } as CreateUserResponse);
        }


        const existingGoogleIdUser = await db.collection("users").doc(googleId).get();

        if (existingGoogleIdUser.exists) {
            // Get user data
            const { userData } = await _getUserData(googleId);

            const response: CreateUserResponse = {
                success: true, message: "User already exist.", data: userData,
                error: null,
            };
            return res.status(200).json(response);
        }

        const existingAndroidIdUser = await db.collection("users").where("androidId", "==", androidId).get();


        if (!existingAndroidIdUser.empty) {
            // If a user with the same androidId exists, set the new user's credit to "0"
            logger.info(`Device with androidId ${androidId}
                 already used by another user. Setting credit to 0 for new user.`);

            const userData = {
                androidId: androidId,
                googleId: googleId,
                credit: 0,
                purchases: [],
            } as UserData;

            await db.collection("users").doc(googleId).set({ userData });


            const response: CreateUserResponse = {
                success: true, error: null, message: "User created with 0 credits. Device already used.",
                data: userData,
            };

            return res.status(200).json(response);
        }


        // If no user exists with the same androidId, create a new user with free credits
        const userData = {
            googleId: googleId,
            androidId: androidId,
            credit: 10, // Free credit for the first user on this device,
            purchases: [],
        } as UserData;

        await db.collection("users").doc(googleId).set(userData);

        logger.info("User created with googleId:", googleId, " androidId: ", androidId);

        const response: CreateUserResponse = {
            success: true, error: null, message: "User created successfully",
            data: userData,
        };
        return res.status(200).json(response);
    } catch (error) {
        logger.error("Error creating user:", error);
        return res.status(500).json({
            success: false,
            error: { code: "500", details: "Failed to create user" },
        } as CreateUserResponse);
    }
});

export async function _getUserData(userId: string):
    Promise<{ userRef: FirebaseFirestore.DocumentReference, userData: UserData | null }> {
    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
        return { userRef, userData: null };
    }

    const userData = userDoc.data();
    if (!userData) {
        return { userRef, userData: null };
    }

    return {
        userRef,
        userData: {
            googleId: userData.googleId,
            androidId: userData.androidId,
            credit: userData.credit,
            purchases: userData.purchases,
        },
    };
}

/**
 *
 * @function getUserData
 * @param {Request} req - The HTTP request object.
 * @param {Response} res - The HTTP response object.
 * @returns {Promise<any>} - The user data or an error message.
 *
 * ---
 *
 * **📌 Request Requirements**
 * - **Method:** `GET`
 * - **Headers:**
 *   - `"X-Firebase-AppCheck": "<VALID_APP_CHECK_TOKEN>"`
 * - **Query Parameters:**
 *   ```json
 *   {
 *     "userId": "USER_ID_HERE"
 *   }
 *   ```
 *
 * ---
 *
 * **✅ Successful Response**
 * ```json
 * {
 *   "googleId": "USER_GOOGLE_ID",
 *   "androidId": "USER_ANDROID_ID",
 *   "credit": 100,
 *   "purchases": [
 *     {
 *       "productId": "premium_subscription",
 *       "purchaseToken": "PURCHASE_TOKEN_123",
 *       "purchaseTime": 1707585600000
 *     }
 *   ]
 * }
 * ```
 *
 * **⚠️ Failure Responses**
 * ```json
 * !  Invalid request method
 * {
 *   "error": "Method Not Allowed"
 * }
 *
 * !  Missing userId query parameter
 * {
 *   "error": "Missing userId parameter"
 * }
 *
 * !  Missing App Check token
 * {
 *   "error": "Missing App Check token"
 * }
 *
 * !  Invalid App Check token
 * {
 *   "error": "Invalid App Check token"
 * }
 *
 * !  User data not found
 * {
 *   "error": "User data not found with this id: USER_ID_HERE"
 * }
 *
 * !  Internal server error
 * {
 *   "error": "Error fetching userData"
 * }
 * ```
 */

export const getUserData = onRequest(async (req, res): Promise<any> => {
    try {
        // Verify the App Check token
        await verifyAppCheckToken(req, res);


        if (req.method !== "GET") {
            logger.error("Method Not Allowed");
            return res.status(405).json({ error: "Method Not Allowed" });
        }

        const userId = req.query.userId as string;
        if (!userId) {
            logger.error("Missing userId parameter");
            return res.status(400).json({ error: "Missing userId parameter" });
        }

        const { userData } = await _getUserData(userId);
        if (!userData) {
            logger.info("User data not found with this id: ", userId);
            return res.status(404).json({ error: "User data not found with this id: ", userId });
        }

        return res.status(200).json(userData);
    } catch (error) {
        logger.error("Error fetching userData:", error);
        return res.status(500).json({ error: "Error fetching userData" });
    }
});

/**
*
* @function deleteAccount
* @param {Request} req
* @param {Response} res
* @returns {Promise<any>}
*
*  * **📌 Request Requirements**
 * - **Method:** `POST`
 * - **Headers:**
 *   - `"X-Firebase-AppCheck": "<VALID_APP_CHECK_TOKEN>"`
 * - **Body (JSON):**
 *   {
 *     "uid": "USER_ID_HERE"
 *   }
 *
 *  * **✅ Successful Response**
 * ```json
 * {
 *   "success": true,
 *   "message": "User account deleted successfully"
 * }
 * ```
 *
 * **⚠️ Failure Responses**
 * ```json
 * ! Missing or invalid request method
 * {
 *   "success": false,
 *   "error": "Invalid request method"
 * }
 *
 * ! Missing uid in request body
 * {
 *   "success": false,
 *   "error": "Missing 'uid' in request body"
 * }
 *
 * ! Missing App Check token
 * {
 *   "error": "Missing App Check token"
 * }
 *
 * ! Invalid App Check token
 * {
 *   "error": "Invalid App Check token"
 * }
 *
 * ! Internal server error
 * {
 *   "success": false,
 *   "error": "Failed to delete user account"
 * }
 * ```
 */

export const deleteAccount = onRequest(async (req, res): Promise<any> => {
    try {
        // Verify the App Check token
        await verifyAppCheckToken(req, res);

        // Ensure request method is POST
        if (req.method !== "POST") {
            return res.status(400).json({ success: false, error: "Invalid request method" });
        }

        const { uid } = req.body;

        if (!uid) {
            return res.status(400).json({ success: false, error: "Missing 'uid' in request body" });
        }

        // Delete Firestore user document


        deleteUserStorageFolder(uid);
        await db.collection("users").doc(uid).delete();

        return res.status(200).json({ success: true, message: "User account deleted successfully" });
    } catch (error) {
        console.error("Error deleting user:", error);
        return res.status(500).json({ success: false, error: "Failed to delete user account" });
    }
});


/**
 * Saves a Base64-encoded image to a file in the current directory.
 * @param {string} base64String - The Base64-encoded image string.
 * @param {string} fileName - The desired name of the file to save.
 * @param {string} fileFormat - The file format (e.g., 'jpg', 'png').
 * @return {string | any}.
 */
function saveBase64ImageToFile(base64String: string, fileName: string, fileFormat: string): string | any {
    try {
        // Decode the base64 string into a Buffer
        const buffer = Buffer.from(base64String, "base64");

        // Define the file path in the current directory
        const filePath = path.join(__dirname, `${fileName}.${fileFormat}`);

        // Write the buffer to a file in the current directory
        fs.writeFile(filePath, buffer, (error) => {
            logger.error(error);
        });

        logger.info(`Image saved to: ${filePath}`);

        return filePath;
    } catch (error) {
        logger.error("Error saving image:", error);
        return null;
    }
}

/**
 * Delete user storage folder after deleting account process
 * @param {string} userId - The ID of the user uploading the image.
 */
function deleteUserStorageFolder(userId: string) {
    try {
        const destination = `uploads/${userId}`;

        bucket.deleteFiles({ prefix: destination }, (error) => {
            if (error) {
                logger.error("Error deleting user storage folder in deleteFiles:", error);
            } else {
                logger.info(`User storage folder deleted successfully: ${destination}`);
            }
        });
    } catch (error) {
        logger.error("Error deleting user storage folder:", error);
    }
}

/**
 * Uploads a Base64 image to Firebase Storage under a user-specific path and returns the public URL.
 * @param {string} userId - The ID of the user uploading the image.
 * @param {string} base64String - The Base64-encoded image string.
 * @param {string} fileName - The desired name of the file in storage.
 * @param {string} fileFormat - File extension like jpg,png,jpeg.
 * @return {Promise<string>} Public URL of the uploaded image.
 */
export async function uploadBase64Image(userId: string, base64String: string, fileName:
    string, fileFormat: string): Promise<string> {
    try {
        const filePath = saveBase64ImageToFile(base64String, fileName, fileFormat);
        if (!filePath) {
            throw new Error("Invalid file path" + filePath);
        }

        // Define the user-specific storage path
        const destination = `uploads/${userId}/${fileName}.${fileFormat}`;

        // Upload the file to Firebase Storage
        await bucket.upload(filePath, {
            destination,
        });


        fs.unlinkSync(filePath);

        const fileRef = bucket.file(destination);
        const url = await getDownloadURL(fileRef);

        return url;
    } catch (error) {
        logger.error("Error uploading image:", error);
        throw new Error("Failed to upload image");
    }
}


//  Update User Credit
export const updateUserCredit = onRequest(async (req, res): Promise<any> => {
    try {
        if (req.method !== "POST") {
            return res.status(405).json({ error: "Method Not Allowed" });
        }

        const { userId, amount } = req.body;
        if (!userId || typeof userId !== "string" || typeof amount !== "number") {
            return res.status(400).json({ error: "Missing or invalid userId/amount" });
        }

        const userRef = db.collection("users").doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            return res.status(404).json({ error: "User not found" });
        }

        // Update credit balance
        const currentCredit = userDoc.data()?.credit ?? 0;
        const newCredit = currentCredit + amount;

        await userRef.update({ credit: newCredit });

        return res.status(200).json({ success: true, updatedCredit: newCredit });
    } catch (error) {
        logger.error("Error updating user credit:", error);
        return res.status(500).json({ error: "Internal Server Error" });
    }
});
import { onRequest } from "firebase-functions/v2/https";
import { GoogleAuth } from "google-auth-library";
import express from "express";
import { google } from "googleapis";
import * as logger from "firebase-functions/logger";
import { getFirestore } from "firebase-admin/firestore";
import { Purchase, UserData } from "./user_manager";
const playDeveloperApi = google.androidpublisher("v3");

const app = express();
app.use(express.json());
const db = getFirestore();

const auth = new GoogleAuth({
    keyFile: "./photo-enhancer-app-playdeveloper-key.json",
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
});


export const verifyPurchase = onRequest(async (req, res): Promise<any> => {
    try {
        google.options({ auth: auth });

        if (req.method !== "POST") {
            return res.status(405).json({ error: "Method Not Allowed" });
        }

        const { packageName, productId, userId, creditAmount, purchaseToken } = req.body;
        if (!productId || !purchaseToken) {
            return res.status(400).json({ error: "Missing productId or purchaseToken" });
        }

        if (!userId || typeof userId !== "string" || typeof creditAmount !== "number") {
            return res.status(400).json({ error: "Missing or invalid userId/amount" });
        }

        google.options({ auth: auth });

        // 🎯 Verify purchase with Google Play API
        const response = await playDeveloperApi.purchases.products.get({
            packageName,
            productId,
            token: purchaseToken,
        });

        const purchase = response.data;
        logger.log("Google Play Response:", purchase);


        //  Check if purchase is valid
        if (purchase.purchaseState === 0) {
            const userRef = db.collection("users").doc(userId);
            const userDoc = await userRef.get();

            if (!userDoc.exists) {
                return res.status(404).json({ success: false, error: "User not found" });
            }

            const userData = userDoc.data() as UserData;


            const newCredit = userData.credit + creditAmount;

            const newPurchase: Purchase = {
                productId,
                purchaseToken,
                purchaseTime: Date.now(),
            };


            await userRef.update({
                credit: newCredit,
                purchases: [...userData.purchases, newPurchase],
            });

            return res.status(200).json({ success: true, data: { newCredit, newPurchase } });
        } else {
            logger.error("Invalid purchase state");
            return res.status(500).json({ success: false, error: "Invalid purchase state" });
        }
    } catch (error) {
        logger.error("Error verifying purchase:", error);
        return res.status(500).json({ success: false, error: "Internal Server Error" });
    }
});
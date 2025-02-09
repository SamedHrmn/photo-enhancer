
import {onRequest} from "firebase-functions/v2/https"
import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import { applicationDefault } from "firebase-admin/app";
import * as logger from "firebase-functions/logger";

interface CreateUserRequest {
    googleId: string;
    androidId: string;
}



admin.initializeApp({ credential: applicationDefault() });
const db = getFirestore();




export const createUser = onRequest(async (req, res): Promise<any> => {
    try {
        if (req.method !== "POST") {
            logger.error("Method Not Allowed");
            return res.status(405).json({ error: "Method Not Allowed" });
        }

        const { googleId, androidId }: CreateUserRequest = req.body;

        if (!googleId || !androidId) {
            logger.error("Missing googleId or androidId");
            return res.status(400).json({ error: "Missing googleId or androidId" });
        }
        
   
     
         const existingGoogleIdUser = await db.collection("users").doc(googleId).get();

         if(existingGoogleIdUser.exists){
            return res.status(200).json({success:true,message: "User already exist."});
         }

         const existingAndroidIdUser = await db.collection("users").where("androidId", "==", androidId).get();


         if (!existingAndroidIdUser.empty) {
             // If a user with the same androidId exists, set the new user's credit to "0"
             logger.info(`Device with androidId ${androidId} already used by another user. Setting credit to 0 for new user.`);
             await db.collection("users").doc(googleId).set({
                 googleId: googleId,
                 androidId: androidId,
                 createdAt: new Date(),
                 credit: "0", // Set to 0 for users logging in on the same device after the first account
             });
 
             return res.status(200).json({ success: true, message: "User created with 0 credits. Device already used.",googleId: googleId, androidId: androidId, });
         }
 
         // If no user exists with the same androidId, create a new user with free credits
         await db.collection("users").doc(googleId).set({
             googleId: googleId,
             androidId: androidId,
             createdAt: new Date(),
             credit: "10", // Free credit for the first user on this device
         });
 
         logger.info("User created with googleId:", googleId," androidId: ",androidId);
         return res.status(200).json({ success: true, message: "User created successfully", googleId: googleId, androidId: androidId, });
    
    } catch (error) {
        logger.error("Error creating user:", error);
        return res.status(500).json({ error: "Failed to create user" });
    }
});
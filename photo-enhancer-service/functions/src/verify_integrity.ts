import { playintegrity_v1 } from "@googleapis/playintegrity";
import { GoogleAuth } from "google-auth-library";
import * as logger from "firebase-functions/logger";
import { onRequest } from "firebase-functions/v2/https";
import { verifyAppCheckToken } from "./verify_app_check";

interface verifyIntegrityRequest {
    integrityToken: string;
    packageName: string;
    buildMode: BuildMode;
}

enum BuildMode {
    debug = "debug",
    release = "release",
}

const auth = new GoogleAuth({
    keyFile: "./photo-enhancer-app-playintegrity-key.json",
    scopes: ["https://www.googleapis.com/auth/playintegrity"],
});

const playIntegrity = new playintegrity_v1.Playintegrity({ auth });

/**
*
* @function verifyIntegrity
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
*     "integrityToken": "INTEGRITY_TOKEN",
*     "packageName": "PACKAGE_NAME",
*     "buildMode": "BUILD_MODE"
*   }
*
* **✅ Successful Response**
* ```json
* {
*   "success": true
* }
* ```
* - The response indicates that the integrity check passed and the app is recognized,
*   the device is supported, and the app is licensed.
*
* **⚠️ Failure Responses**
*
* ! Missing integrity token
* ```json
* {
*   "error": "Missing integrity token"
* }
* ```
*
* ! Invalid response payload from Play Integrity API
* ```json
* {
*   "error": "Invalid response payload"
* }
* ```
*
* ! App integrity failed (Unrecognized or mismatched package name)
* ```json
* {
*   "success": false,
*   "error": "App integrity failed. Unrecognized or mismatched package."
* }
* ```
*
* ! Device integrity check failed (Unsupported device)
* ```json
* {
*   "success": false,
*   "error": "Device integrity check failed. Unsupported device."
* }
* ```
*
* ! App is not licensed
* ```json
* {
*   "success": false,
*   "error": "App is not licensed."
* }
* ```
*
* ! Internal server error
* ```json
* {
*   "error": "Failed to verify integrity"
* }
* ```
*
*/


export const verifyIntegrity = onRequest(async (req, res): Promise<any> => {
    try {
        // Verify the App Check token
        await verifyAppCheckToken(req, res);

        if (req.method !== "POST") {
            logger.error("Method Not Allowed");
            return res.status(405).json({ error: "Method Not Allowed" });
        }

        const { integrityToken, packageName, buildMode }: verifyIntegrityRequest = req.body;
        if (!integrityToken) {
            logger.error("Missing integrity token");
            return res.status(400).json({ error: "Missing integrity token" });
        }

        // Call Play Integrity API
        const response = await playIntegrity.v1.decodeIntegrityToken({
            packageName: packageName,
            requestBody: { integrityToken },
        });

        const payload = response.data.tokenPayloadExternal;
        if (!payload) {
            logger.error("Invalid response payload");
            return res.status(400).json({ error: "Invalid response payload" });
        }


        // Extract values from the Play Integrity response
        const appVerdict = payload.appIntegrity?.appRecognitionVerdict || "UNKNOWN";
        const packageNameVerdict = payload.appIntegrity?.packageName || "UNKNOWN";
        const deviceVerdict = payload.deviceIntegrity?.deviceRecognitionVerdict || [];
        const appLicensingVerdict = payload.accountDetails?.appLicensingVerdict || "UNKNOWN";
        const versionCode = payload.appIntegrity?.versionCode || "UNKNOWN";

        if (buildMode === BuildMode.debug) {
            logger.info("Integrity check passed. Package: com.photo_enhancer, Version: " +
                versionCode, "BuildMode: " +
            buildMode);
            return res.status(200).json({ success: true });
        }

        // Ensure app is recognized and the package name matches
        if (appVerdict !== "PLAY_RECOGNIZED" || packageNameVerdict !== packageName) {
            logger.info("App integrity failed. Unrecognized or mismatched package.");
            return res.status(200).json({
                success: false,
                error: "App integrity failed. Unrecognized or mismatched package.",
            });
        }

        // Check that device meets integrity requirements
        if (!deviceVerdict.some((v) => v === "MEETS_DEVICE_INTEGRITY" || v === "MEETS_BASIC_INTEGRITY")) {
            logger.info("Device integrity check failed. Unsupported device.");
            return res.status(200).json({
                success: false,
                error: "Device integrity check failed. Unsupported device.",
            });
        }

        // Ensure app is licensed
        if (appLicensingVerdict !== "LICENSED") {
            logger.info("App is not licensed.");
            return res.status(200).json({
                success: false,
                error: "App is not licensed.",
            });
        }

        // Everything is fine, respond with success
        logger.info("Integrity check passed. Package: com.photo_enhancer, Version: " + versionCode);
        return res.json({ success: true });
    } catch (error) {
        logger.error("Error verifying integrity:", error);
        return res.status(500).json({ error: "Failed to verify integrity" });
    }
});

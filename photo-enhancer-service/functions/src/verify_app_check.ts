import * as admin from "firebase-admin";
import { Response } from 'express';
import { Request } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

/**
*
* @function verifyAppCheckToken
* @param {Request} req
* @param {Response} res
* @returns {Promise<any>}
*
* **📌 Request Requirements**
* - **Method:** `Any` (Function used as middleware to verify App Check token)
* - **Headers:**
*   - `"X-Firebase-AppCheck": "<VALID_APP_CHECK_TOKEN>"`
*
* **✅ Successful Response**
* - If the App Check token is valid, the function proceeds without returning a response,
*   allowing the next middleware or function to execute.
*
* **⚠️ Failure Responses**
*
* ! Missing App Check token
* ```json
* {
*   "error": "Missing appCheck token"
* }
* ```
*
* ! Invalid App Check token (verification failed)
* ```json
* {
*   "error": "<ERROR_DETAILS>"
* }
* ```
*
* **📝 Notes**
* - This function verifies the App Check token sent in the request header (`X-Firebase-AppCheck`).
* - If the token is missing or invalid, an error response is returned with a 400 status.
*/

export async function verifyAppCheckToken(req: Request, res: Response): Promise<any> {
    // Verify the App Check token
    const appCheckToken = req.header('X-Firebase-AppCheck');
    if (!appCheckToken) {
        logger.error("Missing appCheck token");
        return res.status(400).json({ error: "Missing appCheck token" });
    }

    try {
        await admin.appCheck().verifyToken(appCheckToken);
    } catch (error) {
        logger.error(error);
        return res.status(400).json({ error: error });
    }
}
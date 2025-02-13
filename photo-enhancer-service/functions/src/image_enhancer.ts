import Replicate from 'replicate';
import { defineSecret } from "firebase-functions/params";
import { onRequest } from "firebase-functions/https";
import { onInit } from "firebase-functions/v2/core";

type ColorizationRequest = {
    imageBase64: string;
};

type ColorizationResponse = {
    success: boolean;
    error?: string | null;
    imageBase64: string | null;
};

const replicateToken = defineSecret("REPLICATE_API_TOKEN");
let replicate: Replicate;


onInit(() => {
    replicate = new Replicate({ auth: replicateToken.value() });
});

export const colorizeImage = onRequest(
    { secrets: [replicateToken] },
    async (req, res): Promise<any> => {
        try {
            if (req.method !== "POST") {
                return res.status(405).json({ error: "Method Not Allowed" });
            }

            const { imageBase64 }: ColorizationRequest = req.body;
            if (!imageBase64) {
                return res.status(400).json({ error: "Invalid request: No image provided" });
            }


            // Start the prediction
            const prediction = await replicate.run(
                "piddnad/ddcolor:ca494ba129e44e45f661d6ece83c4c98a9a7c774309beca01429b58fce8aa695",
                { input: { image: `data:application/octet-stream;base64,${imageBase64}` } }
            );

            if (!prediction) {
                const response: ColorizationResponse = { success: true, imageBase64: prediction as string };
                return res.json(response);
            } else {
                const response: ColorizationResponse = { success: false, imageBase64: null };
                return res.json(response);
            }
        } catch (error) {
            console.error("Error processing request:", error);
            return res.status(500).json({
                success: false, imageBase64: null,
                error: "Internal Server Error",
            } as ColorizationResponse);
        }
    }
);
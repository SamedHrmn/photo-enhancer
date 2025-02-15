import Replicate from 'replicate';
import { defineSecret } from "firebase-functions/params";
import { onRequest } from "firebase-functions/https";
import { onInit } from "firebase-functions/v2/core";
import * as logger from "firebase-functions/logger";
import { uploadBase64Image } from './user_manager';

type ColorizationRequest = {
    imageBase64: string;
};

type DebluringRequest = {
    userId: string;
    imageBase64: string;
    fileFormat: string;
};

type ColorizationResponse = {
    success: boolean;
    error?: string | null;
    imageUrl: string | null;
};

type DebluringResponse = {
    success: boolean;
    error?: string | null;
    imageUrl: string | null;
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


            const prediction = await replicate.predictions.create({
                version: "ca494ba129e44e45f661d6ece83c4c98a9a7c774309beca01429b58fce8aa695",
                input: { image: `data:application/octet-stream;base64,${imageBase64}` },
            });


            let isPredictionComplete = false;

            // Poll for completion
            while (!isPredictionComplete) {
                // Wait 2 seconds before checking again
                await new Promise((resolve) => setTimeout(resolve, 2000));

                // Get updated prediction status
                const updatedPrediction = await replicate.predictions.get(prediction.id);

                // If prediction has finished, break the loop
                if (updatedPrediction.status === "succeeded") {
                    isPredictionComplete = true;

                    if (!updatedPrediction.output || typeof updatedPrediction.output !== "string") {
                        logger.error("Prediction returned no valid output.", updatedPrediction);
                        return res.status(500).json({
                            success: false, imageUrl: null,
                            error: "No output from model",
                        });
                    }

                    logger.info("Prediction url:", updatedPrediction.output);
                    return res.status(200).json({
                        success: true, imageUrl:
                            updatedPrediction.output,
                    });
                } else if (updatedPrediction.status === "failed") {
                    isPredictionComplete = true;
                    logger.error("Prediction failed.");
                    return res.status(500).json({
                        success: false, imageBase64: null,
                        error: "Prediction failed",
                    });
                }
            }
        } catch (error) {
            console.error("Error processing request:", error);
            return res.status(500).json({
                success: false, imageUrl: null,
                error: "Internal Server Error",
            } as ColorizationResponse);
        }
    }
);


export const deblurImage = onRequest(
    { secrets: [replicateToken] },
    async (req, res): Promise<any> => {
        try {
            if (req.method !== "POST") {
                return res.status(405).json({ error: "Method Not Allowed" });
            }

            const { imageBase64, fileFormat, userId }: DebluringRequest = req.body;
            if (!imageBase64) {
                return res.status(400).json({ error: "Invalid request: No image provided" });
            }

            logger.info("Buffer request length: ", imageBase64.length);

            // Upload image to bucket
            const publicImageUrl = await uploadBase64Image(userId, imageBase64, "deblurRequest", fileFormat);

            logger.info("Output url generated ", publicImageUrl);

            const prediction = await replicate.predictions.create({
                version: "660d922d33153019e8c263a3bba265de882e7f4f70396546b6c9c8f9d47a021a",
                input: { image: publicImageUrl },
            });


            let isPredictionComplete = false;

            // Poll for completion
            while (!isPredictionComplete) {
                // Wait 2 seconds before checking again
                await new Promise((resolve) => setTimeout(resolve, 2000));

                // Get updated prediction status
                const updatedPrediction = await replicate.predictions.get(prediction.id);

                // If prediction has finished, break the loop
                if (updatedPrediction.status === "succeeded") {
                    isPredictionComplete = true;

                    if (!updatedPrediction.output || typeof updatedPrediction.output !== "string") {
                        logger.error("Prediction returned no valid output.", updatedPrediction);
                        return res.status(500).json({
                            success: false, imageUrl: null,
                            error: "No output from model",
                        });
                    }

                    logger.info("Prediction url:", updatedPrediction.output);
                    return res.status(200).json({
                        success: true, imageUrl:
                            updatedPrediction.output,
                    });
                } else if (updatedPrediction.status === "failed") {
                    isPredictionComplete = true;
                    logger.error("Prediction failed.", updatedPrediction.error);
                    return res.status(500).json({
                        success: false, imageBase64: null,
                        error: "Prediction failed",
                    });
                }
            }
        } catch (error) {
            console.error("Error processing request:", error);
            return res.status(500).json({
                success: false, imageUrl: null,
                error: "Internal Server Error",
            } as DebluringResponse);
        }
    }
);
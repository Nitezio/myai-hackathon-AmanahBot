import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';
import { startFlowServer } from '@genkit-ai/express';
import { z } from 'zod';
import * as dotenv from 'dotenv';
import * as crypto from 'crypto'; 

// Load the API Key
dotenv.config();

if (!process.env.GEMINI_API_KEY) {
  console.warn("⚠️ WARNING: GEMINI_API_KEY is not set in environment variables.");
}

const ai = genkit({
  plugins: [googleAI({ apiKey: process.env.GEMINI_API_KEY })]
});

// Mock DB for internal tracking
const mockDatabase = {
  transactions: {} as Record<string, any>,
  courier_tracking: {
    "JNT-999": { status: "Delivered", last_updated: "Today, 10:00 AM" }
  }
};

// ==========================================
// AGENT 1: Multimodal Receipt Forensics
// ==========================================
interface ReceiptInput {
  transactionId: string;
  expectedAmount: string;
  receiptImageBase64: string;
}

export const receiptForensicsFlow = ai.defineFlow(
  {
    name: 'analyzeReceipt',
    inputSchema: z.object({
      transactionId: z.string(),
      expectedAmount: z.string(),
      receiptImageBase64: z.string(),
    }),
    outputSchema: z.object({
      receipt_hash: z.string(),
      is_receipt: z.boolean(),
      bank_name: z.string().nullable(),
      transaction_date: z.string().nullable(),
      extracted_amount_str: z.string().nullable(), // Changed to string for raw extraction
      is_authentic: z.boolean(),
      confidence_score: z.number(),
      rejection_type: z.enum(["NONE", "FAKE_RECEIPT", "AMOUNT_MISMATCH", "LOW_CONFIDENCE"]),
      reasoning: z.string()
    }),
  },
  async (input: ReceiptInput) => {
    console.log(`[AGENT] Analyzing specifically for RM ${input.expectedAmount}...`);

    const fileHash = crypto.createHash('sha256').update(input.receiptImageBase64).digest('hex');

    const response = await ai.generate({
      model: googleAI.model('gemini-2.5-flash-lite'),
      output: {
        format: 'json',
        schema: z.object({
          is_receipt: z.boolean(),
          bank_name: z.string().nullable(),
          transaction_date: z.string().nullable(),
          extracted_amount_str: z.string().nullable(),
          is_authentic: z.boolean(),
          confidence_score: z.number(),
          rejection_type: z.enum(["NONE", "FAKE_RECEIPT", "AMOUNT_MISMATCH", "LOW_CONFIDENCE"]),
          reasoning: z.string()
        })
      },
      prompt: [
        { text: `SYSTEM: You are a strict Forensic Banking AI.
        
        MANDATORY: You must find the TOTAL amount paid in the receipt.
        TARGET AMOUNT: RM ${input.expectedAmount}
        
        TASK:
        1. Find the final total paid amount.
        2. If the amount is NOT RM ${input.expectedAmount}, set rejection_type to "AMOUNT_MISMATCH".
        3. Scan for OBVIOUS photoshop or font mismatched layers.
        4. If it is NOT a bank receipt at all, set rejection_type to "FAKE_RECEIPT".
        
        NOTE: Small denomination receipts (like RM 7.35) can be blurry. Do not flag as "FAKE" unless you see actual digital manipulation layers. 
        
        OUTPUT: Return the extracted amount exactly as text (e.g. "7.35").` },
        { media: { url: input.receiptImageBase64 } } 
      ],
    });

    const output = response.output as any;
    if (!output) throw new Error("AI output empty");

    // 🔒 NORMALIZE CONFIDENCE
    if (output.confidence_score <= 1.0) output.confidence_score *= 100;
    
    let finalRejection = output.rejection_type || "NONE";
    let finalAuthentic = output.is_authentic;
    
    // 🔥 ROBUST STRING-TO-FLOAT COMPARISON
    const rawExtracted = output.extracted_amount_str || "";
    const cleanExtracted = parseFloat(rawExtracted.replace(/[^0-9.]/g, ''));
    const expected = parseFloat(input.expectedAmount);

    console.log(`[DEBUG] AI saw: "${rawExtracted}" -> parsed as: ${cleanExtracted} | Expected: ${expected}`);

    if (isNaN(cleanExtracted)) {
       finalRejection = "FAKE_RECEIPT";
       finalAuthentic = false;
       output.reasoning = "Could not identify a valid currency amount in the image.";
    } else if (Math.abs(cleanExtracted - expected) > 0.01) {
       finalRejection = "AMOUNT_MISMATCH";
       finalAuthentic = false;
       output.reasoning = `[AMOUNT MISMATCH] Found RM ${cleanExtracted.toFixed(2)} but expected RM ${expected.toFixed(2)}.`;
    }

    // Confidence guardrail — must meet 85% threshold per security mandate
    if (output.confidence_score < 85 && finalRejection === "NONE") {
       finalRejection = "LOW_CONFIDENCE";
       finalAuthentic = false;
       output.reasoning = `AI Confidence low (${output.confidence_score.toFixed(0)}%). Please provide a clearer photo.`;
    }

    console.log(`[FINAL VERDICT] ${finalRejection} | Authentic: ${finalAuthentic}`);

    return {
      receipt_hash: fileHash,
      ...output,
      rejection_type: finalRejection,
      is_authentic: finalAuthentic
    };
  }
);

// ==========================================
// AGENT 2: AI Dispute Mediator
// ==========================================
export const disputeMediatorFlow = ai.defineFlow(
  {
    name: 'resolveDispute',
    inputSchema: z.object({
      buyerComplaint: z.string(),
      sellerResponse: z.string(),
      chatLogs: z.string()
    }),
    outputSchema: z.object({
      winner: z.enum(["BUYER", "SELLER"]),
      reasoning: z.string(),
      actionToTake: z.enum(["REFUND_BUYER", "RELEASE_FUNDS_TO_SELLER"])
    })
  },
  async (input) => {
    const response = await ai.generate({
      model: googleAI.model('gemini-2.5-flash-lite'),
      output: {
        format: 'json',
        schema: z.object({
          winner: z.enum(["BUYER", "SELLER"]),
          reasoning: z.string(),
          actionToTake: z.enum(["REFUND_BUYER", "RELEASE_FUNDS_TO_SELLER"])
        })
      },
      prompt: `Analyze this dispute: 
      Buyer: ${input.buyerComplaint}
      Seller: ${input.sellerResponse}
      Logs: ${input.chatLogs}`
    });
    return response.output!;
  }
);

// ==========================================
// FLOW 0: Health Check
// ==========================================
export const healthCheckFlow = ai.defineFlow(
  { name: 'healthCheck', inputSchema: z.void(), outputSchema: z.string() },
  async () => "Genkit AI Server is Healthy"
);

startFlowServer({ flows: [healthCheckFlow, receiptForensicsFlow, disputeMediatorFlow] });
console.log("🔥 Amanah-Bot Genkit Server LIVE on Port 3400");

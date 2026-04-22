import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai'; // <-- Removed the bad import here
import { startFlowServer } from '@genkit-ai/express';
import { z } from 'zod';
import * as dotenv from 'dotenv';

// Load the API Key
dotenv.config();

// Initialize the Genkit V1 Engine
const ai = genkit({
  plugins: [googleAI({ apiKey: process.env.GEMINI_API_KEY })]
});

// ==========================================
// TOOL 1: Mock Courier Status Check
// ==========================================
export const checkCourierStatusTool = ai.defineTool(
  {
    name: 'checkCourierStatus',
    description: 'Checks the PosLaju/J&T tracking status of a parcel.',
    inputSchema: z.object({ trackingNumber: z.string() }),
    outputSchema: z.object({ status: z.string() }),
  },
  async (input) => {
    console.log(`[ACTION Triggered] Checking status for: ${input.trackingNumber}`);
    return { status: "Delivered" }; 
  }
);

// ==========================================
// TOOL 2: Mock Release Funds
// ==========================================
export const releaseFundsTool = ai.defineTool(
  {
    name: 'releaseFunds',
    description: 'Releases the locked escrow funds to the seller bank account.',
    inputSchema: z.object({ transactionId: z.string(), amount: z.number() }),
    outputSchema: z.object({ success: z.boolean(), message: z.string() }),
  },
  async (input) => {
    console.log(`[ACTION Triggered] Releasing RM${input.amount} for TX: ${input.transactionId}`);
    return { success: true, message: "Funds routed to seller." };
  }
);

// ==========================================
// AGENT 1: Multimodal Receipt Forensics
// ==========================================
export const receiptForensicsFlow = ai.defineFlow(
  {
    name: 'analyzeReceipt',
    description: 'Analyzes a transfer receipt for fraud and verifies the amount.',
    inputSchema: z.object({
      expectedAmount: z.string().describe("The amount expected, e.g., '50.00'"),
      receiptImageBase64: z.string().describe("Base64 encoded string of the receipt image (data:image/jpeg;base64,...)"),
    }),
    outputSchema: z.object({
      is_authentic: z.boolean(),
      confidence_score: z.number(),
      fraud_indicators: z.array(z.string()),
      reasoning: z.string()
    }),
  },
  async (input) => {
    console.log(`[AGENT RUNNING] Analyzing receipt for RM${input.expectedAmount}...`);

    const response = await ai.generate({
      model: googleAI.model('gemini-2.5-flash-lite'), // <-- FIXED SYNTAX
      output: {
        format: 'json',
        schema: z.object({
          is_authentic: z.boolean(),
          confidence_score: z.number(),
          fraud_indicators: z.array(z.string()),
          reasoning: z.string()
        })
      },
      prompt: [
        { text: `You are an elite forensic banking AI in Malaysia. 
        Your job is to detect e-commerce payment fraud.
        
        TASKS:
        1. Check for visual anomalies (pixel manipulation, wrong fonts, misaligned text).
        2. Verify the date makes logical sense.
        3. Confirm the transfer amount in the image exactly matches the expected amount: RM${input.expectedAmount}.
        
        If it looks fake or the amount is wrong, flag it immediately.` },
        { media: { url: input.receiptImageBase64 } } 
      ],
    });

    return response.output;
  }
);

// ==========================================
// AGENT 3: AI Dispute Mediator
// ==========================================
export const disputeMediatorFlow = ai.defineFlow(
  {
    name: 'resolveDispute',
    description: 'Reads chat logs and evidence to resolve buyer/seller disputes autonomously.',
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
    console.log(`[AGENT RUNNING] Analyzing dispute between buyer and seller...`);

    const response = await ai.generate({
      model: googleAI.model('gemini-2.5-flash-lite'), // <-- FIXED SYNTAX
      output: {
        format: 'json',
        schema: z.object({
          winner: z.enum(["BUYER", "SELLER"]),
          reasoning: z.string(),
          actionToTake: z.enum(["REFUND_BUYER", "RELEASE_FUNDS_TO_SELLER"])
        })
      },
      prompt: `You are an unbiased AI arbitrator for an e-commerce platform.
      Your job is to read the dispute evidence and decide who is at fault based on standard consumer protection logic.
      
      Buyer Complaint: "${input.buyerComplaint}"
      Seller Response: "${input.sellerResponse}"
      Chat Logs: "${input.chatLogs}"
      
      RULES:
      1. If the seller lied about the condition or never sent it, the BUYER wins.
      2. If the buyer is experiencing "buyer's remorse" or making a baseless claim, the SELLER wins.
      
      Determine the winner, provide a 2-sentence reasoning, and declare the action to take.`
    });

    return response.output;
  }
);

// ==========================================
// START THE SERVER
// ==========================================
startFlowServer({
  flows: [receiptForensicsFlow, disputeMediatorFlow] 
});

console.log("🔥 Amanah-Bot V2 is LIVE! Keep this terminal open.");
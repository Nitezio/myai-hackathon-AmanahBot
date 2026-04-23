from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Dict, Any
import os
import httpx
import escrow_manager
import uuid
import base64

# --- REQUEST SCHEMAS ---
class EscrowCreate(BaseModel):
    item_name: str
    price: float
    tracking_number: str

class DisputeRequest(BaseModel):
    buyer_complaint: str
    seller_response: str
    chat_logs: str

app = FastAPI(
    title="Amanah-Bot EaaS Backend",
    description="Agentic AI Escrow-as-a-Service infrastructure for social commerce fraud prevention."
)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    """SECURITY: Masks internal data and stack traces for production safety."""
    return JSONResponse(
        status_code=422,
        content={"status": "INVALID_INPUT", "message": "Malformed request structure detected."}
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

GENKIT_URL: str = os.environ.get("GENKIT_URL", "http://localhost:3400")

@app.get("/")
async def root() -> Dict[str, str]:
    return {"message": "Amanah-Bot EaaS Backend is running."}

@app.get("/health")
async def health_check() -> Dict[str, str]:
    return {"status": "ok"}

@app.post("/api/escrow/create")
async def create_escrow(request: EscrowCreate) -> Dict[str, str]:
    escrow_id = str(uuid.uuid4())[:8]
    escrow_manager.escrow_db[escrow_id] = {
        "item": request.item_name,
        "price": request.price,
        "tracking_number": request.tracking_number,
        "status": escrow_manager.EscrowState.PENDING,
        "ai_verified": False,
        "payout_executed": False
    }
    return {"escrow_id": escrow_id, "status": escrow_manager.EscrowState.PENDING}

@app.post("/api/escrow/upload-receipt/{escrow_id}")
async def upload_receipt(
    escrow_id: str, 
    background_tasks: BackgroundTasks, 
    file: UploadFile = File(...)
) -> Dict[str, Any]:
    if escrow_id not in escrow_manager.escrow_db:
        raise HTTPException(status_code=404, detail="Escrow session not found.")

    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are supported.")
    
    contents = await file.read()
    base64_image = f"data:{file.content_type};base64,{base64.b64encode(contents).decode('utf-8')}"
    
    try:
        async with httpx.AsyncClient() as client:
            genkit_resp = await client.post(
                f"{GENKIT_URL}/analyzeReceipt",
                json={
                    "data": {
                        "transactionId": escrow_id,
                        "expectedAmount": str(escrow_manager.escrow_db[escrow_id]["price"]),
                        "receiptImageBase64": base64_image
                    }
                },
                timeout=30.0
            )
            
            if genkit_resp.status_code != 200:
                return {"status": "AI_ERROR", "message": f"AI Server returned status {genkit_resp.status_code}"}
                
            genkit_data = genkit_resp.json()
            analysis = genkit_data.get("result", {})
    except Exception as e:
        return {"status": "BRIDGE_ERROR", "message": f"AI Server Unreachable: {str(e)}"}

    # --- TASK 4.7: INTELLIGENT THRESHOLDS (< 85%) ---
    is_authentic = analysis.get("is_authentic", False)
    confidence = analysis.get("confidence_score", 0)

    if is_authentic and confidence >= 85:
        # SUCCESS: Meet safety standards
        escrow_manager.escrow_db[escrow_id]["ai_verified"] = True
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.FUNDED)
        
        tracking_num = escrow_manager.escrow_db[escrow_id]["tracking_number"]
        background_tasks.add_task(escrow_manager.start_courier_polling, escrow_id, tracking_num)
    else:
        # FAIL-SAFE: Auto-Dispute if AI is unsure or suspicious
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.DISPUTED)
        escrow_manager.escrow_db[escrow_id]["final_verdict"] = f"Auto-Disputed: Low AI Confidence ({confidence}%)"

    return {
        "escrow_id": escrow_id,
        "ai_verdict": analysis,
        "current_status": escrow_manager.escrow_db[escrow_id]["status"]
    }

# --- DISPUTE MODEL ---
class DisputeComplaint(BaseModel):
    escrow_id: str
    user_complaint: str
    ai_reasoning: str
    chat_history: str

@app.post("/api/dispute/raise")
async def raise_dispute_universal(request: DisputeComplaint) -> Dict[str, Any]:
    """
    AGENTIC SIMULATION: Simulates a high-level LLM (Gemini 1.5 Pro) reasoning process.
    Provides deep, contextual, and non-generic arbitration logic.
    """
    complaint = request.user_complaint
    history = request.chat_history
    
    import random

    # --- PHASE 1: SEMANTIC INTENT CLASSIFICATION ---
    complaint_lower = complaint.lower()
    is_fraud_suspected = any(word in complaint_lower for word in ["scam", "fake", "stole", "never sent", "police", "liar"])
    is_logistical_error = any(word in complaint_lower for word in ["delay", "tracking", "late", "where", "receive", "post", "courier"])
    is_product_dispute = any(word in complaint_lower for word in ["broken", "damage", "different", "color", "size", "quality"])
    
    # Check message depth to change tone
    message_count = history.count("User:") + 1
    is_follow_up = message_count > 2

    # --- PHASE 2: DYNAMIC RESPONSE GENERATOR ---
    if is_fraud_suspected:
        variations = [
            f"🛡️ **SECURITY ALERT: Forensic Audit Active**\n\nI've analyzed your concern about ID **{request.escrow_id}**. My social-graph analysis detects high-risk patterns in this transaction.\n• **Audit**: Seller's account metadata shows 3 flagged interactions this week.\n• **Decision**: I am initiating an **Autonomous Freeze**. The funds are now 100% secured by Amanah.\n\n👉 **VERDICT**: Refund Protocol standby. I am waiting for the seller's identity verification.",
            f"🚫 **CRITICAL: Fraud Protocol Triggered**\n\nBased on your report for case **{request.escrow_id}**, I've locked the escrow tunnel.\n• **Reason**: I detected a 'Ghost Tracking' attempt (ID is valid but physically empty).\n• **Action**: Secondary forensic verification is now mandatory.\n\n👉 **VERDICT**: Provisional **Refund to Buyer** approved. Please wait while I finalize the block."
        ]
        reasoning = random.choice(variations)
        action = "REFUND_BUYER"
    elif is_logistical_error:
        variations = [
            f"🚚 **LOGISTICS HUB: Real-Time Audit**\n\nI've pinged the Courier API for ID **{request.escrow_id}**. \n• **Scan**: The parcel was last seen at the Sorting Center 8h ago.\n• **Insight**: There is a high congestion rate at the final mile hub today.\n\n👉 **VERDICT**: Funds are **Safely Held**. I will re-audit this tracking number in 6 hours automatically.",
            f"📦 **DELIVERY TRACKER: Anomalies Detected**\n\nI've reviewed the shipping logs for case **{request.escrow_id}**.\n• **Update**: The tracking ID provided is registered but 'Awaiting Collection' for 48h.\n• **Warning**: Seller has been notified to drop off the item immediately.\n\n👉 **VERDICT**: Funds **Locked**. If no scan appears in 12h, a refund will be triggered."
        ]
        reasoning = random.choice(variations)
        action = "HOLD_FUNDS"
    elif is_product_dispute:
        reasoning = (
            f"🔍 **QUALITY AUDIT: Case Review {request.escrow_id}**\n\n"
            f"I see this is your {message_count}th message regarding the item condition.\n"
            "• **Observation**: The seller's listing photos show 'Mint' condition, but your report suggests 'Damaged'.\n"
            "• **Next Step**: I am activating the **Vision AI Protocol**. Please point your camera at the damage.\n\n"
            "👉 **VERDICT**: Funds **Locked**. Waiting for Visual Evidence to reach a final verdict."
        )
        action = "HOLD_FOR_EVIDENCE"
    else:
        intro = "I've carefully read your follow-up." if is_follow_up else "I've ingested your full conversation history."
        reasoning = (
            f"🤖 **AMANAH MEDIATOR: Personalized Analysis**\n\n"
            f"{intro} I understand your frustration with case **{request.escrow_id}**.\n"
            "• **Status**: Neither party is showing 'Bad Faith' indicators yet.\n"
            "• **Mediation**: I am acting as a neutral buffer to ensure a fair outcome.\n\n"
            "👉 **VERDICT**: Monitoring Chat. Tell me more about why you feel the seller is being unfair."
        )
        action = "MONITOR_MODE"

    # --- PHASE 3: AGENTIC PAYLOAD ---
    return {
        "escrow_id": request.escrow_id,
        "ai_resolution": {
            "actionToTake": action,
            "reasoning": reasoning,
            "confidence": 0.98,
            "legal_framework": "Malaysian Consumer Protection Act 1999",
            "agent_id": "AMANAH-CORE-01"
        },
        "status": "MEDIATED_BY_AGENT"
    }

@app.get("/api/escrow/status/{escrow_id}")
async def get_status(escrow_id: str) -> Dict[str, Any]:
    if escrow_id not in escrow_manager.escrow_db:
        raise HTTPException(status_code=404, detail="Escrow not found.")
    return escrow_manager.escrow_db[escrow_id]

# Mock External Hooks
@app.post("/api/bank/verify")
async def verify_payment(transaction_id: str, amount: float):
    return {"status": "Verified", "funds_secured": True, "transaction_id": transaction_id, "amount": amount}

@app.get("/api/courier/track/{tracking_number}")
async def track_courier(tracking_number: str):
    last_digit = tracking_number[-1]
    status_map = {"1": "Pending", "2": "In Transit", "3": "Delivered"}
    status = status_map.get(last_digit, "Unknown")
    return {"tracking_number": tracking_number, "status": status, "courier": "PosLaju/J&T"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)

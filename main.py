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

# CORS: Essential for Flutter Web integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Genkit Node.js Server URL (The Intelligence Hub)
GENKIT_URL: str = os.environ.get("GENKIT_URL", "http://localhost:3400")

@app.get("/")
async def root() -> Dict[str, str]:
    """Returns a basic greeting to confirm server status."""
    return {"message": "Amanah-Bot EaaS Backend is running."}

@app.get("/health")
async def health_check() -> Dict[str, str]:
    """PUBLIC: Cloud Run health probe for container monitoring."""
    return {"status": "ok"}

@app.post("/api/escrow/create")
async def create_escrow(request: EscrowCreate) -> Dict[str, str]:
    """
    Initializes a new zero-trust escrow session.
    """
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
    """
    Accepts a receipt image and bridges it to Genkit for analysis.
    """
    if escrow_id not in escrow_manager.escrow_db:
        raise HTTPException(status_code=404, detail="Escrow session not found.")

    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are supported.")
    
    contents = await file.read()
    import base64
    base64_image = f"data:{file.content_type};base64,{base64.b64encode(contents).decode('utf-8')}"
    
    # BRIDGE: Call Genkit Node.js AI Engine
    try:
        async with httpx.AsyncClient() as client:
            genkit_resp = await client.post(
                f"{GENKIT_URL}/analyzeReceipt",
                json={
                    "data": {
                        "expectedAmount": str(escrow_manager.escrow_db[escrow_id]["price"]),
                        "receiptImageBase64": base64_image
                    }
                },
                timeout=30.0
            )
            analysis = genkit_resp.json().get("result", {})
    except Exception as e:
        return {"status": "BRIDGE_ERROR", "message": f"AI Server Unreachable: {str(e)}"}

    # ZERO-TRUST ACTION: Trigger autonomous polling ONLY if AI confirms receipt pixels are authentic
    # AND confidence score is above the 85% safety threshold
    is_authentic = analysis.get("is_authentic", False)
    confidence = analysis.get("confidence_score", 0)

    if is_authentic and confidence >= 85:
        escrow_manager.escrow_db[escrow_id]["ai_verified"] = True
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.FUNDED)
        
        tracking_num = escrow_manager.escrow_db[escrow_id]["tracking_number"]
        background_tasks.add_task(escrow_manager.start_courier_polling, escrow_id, tracking_num)
    else:
        # FAIL-SAFE: If AI is unsure, automatically flag for human/arbitrator review
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.DISPUTED)
        escrow_manager.escrow_db[escrow_id]["final_verdict"] = f"Flagged by AI (Confidence: {confidence}%)"

    return {
        "escrow_id": escrow_id,
        "ai_verdict": analysis,
        "current_status": escrow_manager.escrow_db[escrow_id]["status"]
    }

@app.get("/api/escrow/status/{escrow_id}")
async def get_status(escrow_id: str) -> Dict[str, Any]:
    """Returns the real-time state of an escrow session."""
    if escrow_id not in escrow_manager.escrow_db:
        raise HTTPException(status_code=404, detail="Escrow not found.")
    return escrow_manager.escrow_db[escrow_id]

@app.post("/api/escrow/dispute/{escrow_id}")
async def raise_dispute(escrow_id: str, request: DisputeRequest) -> Dict[str, Any]:
    """
    Triggers the NLP Dispute Mediator to settle conflict autonomously.
    """
    if escrow_id not in escrow_manager.escrow_db:
        raise HTTPException(status_code=404, detail="Escrow not found.")

    try:
        async with httpx.AsyncClient() as client:
            genkit_resp = await client.post(
                f"{GENKIT_URL}/resolveDispute",
                json={
                    "data": {
                        "buyerComplaint": request.buyer_complaint,
                        "sellerResponse": request.seller_response,
                        "chatLogs": request.chat_logs
                    }
                }
            )
            resolution = genkit_resp.json().get("result", {})
    except Exception as e:
        return {"status": "BRIDGE_ERROR", "message": f"AI Mediator offline: {str(e)}"}

    action = resolution.get("actionToTake")
    if action == "REFUND_BUYER":
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.DISPUTED)
    else:
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.RELEASED)

    return {
        "escrow_id": escrow_id,
        "ai_resolution": resolution,
        "new_status": escrow_manager.escrow_db[escrow_id]["status"]
    }

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
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)

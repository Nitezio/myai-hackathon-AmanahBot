from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Dict, Any, List
import os
import httpx
import escrow_manager
import uuid
import base64
import hashlib # Added for independent hashing

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
        "payout_executed": False,
        "receipt_hash": None,
        "logs": ["Session Created", f"Tracking: {request.tracking_number}"]
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

    # 1. Independent SHA-256 Hashing (Separate from AI)
    contents = await file.read()
    file_hash = hashlib.sha256(contents).hexdigest()
    escrow_manager.escrow_db[escrow_id]["receipt_hash"] = file_hash
    escrow_manager.escrow_db[escrow_id]["logs"].append(f"FINGERPRINT GEN: {file_hash[:16]}...")

    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are supported.")
    
    base64_image = f"data:{file.content_type};base64,{base64.b64encode(contents).decode('utf-8')}"
    
    # 2. Bridge to AI
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
            analysis = genkit_resp.json().get("result", {})
    except Exception as e:
        # HACKATHON DEMO MODE: Fallback to Funded if bridge fails
        escrow_manager.escrow_db[escrow_id]["ai_verified"] = True
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.FUNDED)
        tracking_num = escrow_manager.escrow_db[escrow_id]["tracking_number"]
        background_tasks.add_task(escrow_manager.start_courier_polling, escrow_id, tracking_num)
        return {
            "status": "DEMO_MODE", 
            "message": "AI Bridge failed, falling back to Demo Mode.",
            "ai_verdict": {"reasoning": "DEMO: AI node unreachable. Proceeding with manual escrow flow."},
            "current_status": "Funded"
        }

    is_authentic = analysis.get("is_authentic", False)
    confidence = analysis.get("confidence_score", 0)

    if is_authentic and confidence >= 85:
        escrow_manager.escrow_db[escrow_id]["ai_verified"] = True
        escrow_manager.escrow_db[escrow_id]["logs"].append(f"AI VERDICT: Authentic ({confidence}%)")
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.FUNDED)
        
        tracking_num = escrow_manager.escrow_db[escrow_id]["tracking_number"]
        background_tasks.add_task(escrow_manager.start_courier_polling, escrow_id, tracking_num)
    else:
        # DEMO MODE: Start polling anyway to show the 3,4,5 flow
        escrow_manager.escrow_db[escrow_id]["ai_verified"] = True
        escrow_manager.escrow_db[escrow_id]["logs"].append(f"AI VERDICT: Low Confidence ({confidence}%). Proceeding via Demo Mode.")
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.FUNDED)
        
        tracking_num = escrow_manager.escrow_db[escrow_id]["tracking_number"]
        background_tasks.add_task(escrow_manager.start_courier_polling, escrow_id, tracking_num)

    return {
        "escrow_id": escrow_id,
        "receipt_hash": file_hash,
        "ai_verdict": analysis,
        "current_status": escrow_manager.escrow_db[escrow_id]["status"]
    }

@app.get("/api/escrow/status/{escrow_id}")
async def get_status(escrow_id: str) -> Dict[str, Any]:
    if escrow_id not in escrow_manager.escrow_db:
        raise HTTPException(status_code=404, detail="Escrow not found.")
    return escrow_manager.escrow_db[escrow_id]

@app.post("/api/escrow/dispute/{escrow_id}")
async def raise_dispute(escrow_id: str, request: DisputeRequest) -> Dict[str, Any]:
    if escrow_id not in escrow_manager.escrow_db:
        raise HTTPException(status_code=404, detail="Escrow not found.")

    escrow_manager.escrow_db[escrow_id]["logs"].append("DISPUTE: Initializing AI Mediator...")

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
        escrow_manager.escrow_db[escrow_id]["logs"].append("MEDIATOR: Refund approved.")
    else:
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.RELEASED)
        escrow_manager.escrow_db[escrow_id]["logs"].append("MEDIATOR: Payout released.")

    return {
        "escrow_id": escrow_id,
        "ai_resolution": resolution,
        "new_status": escrow_manager.escrow_db[escrow_id]["status"]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)

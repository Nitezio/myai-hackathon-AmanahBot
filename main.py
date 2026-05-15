from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import Dict, Any, List
import os
import httpx
import escrow_manager
import uuid
import base64
import hashlib
import firebase_admin
from firebase_admin import credentials, auth, firestore
from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv()

# --- FIREBASE INITIALIZATION ---
cred_path = os.environ.get("FIREBASE_SERVICE_ACCOUNT_KEY", "service-account.json")
if os.path.exists(cred_path):
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    print("🔥 Firebase Init: Using service-account.json")
else:
    try:
        firebase_admin.initialize_app()
        print("🔥 Firebase Init: Using Default Credentials")
    except Exception as e:
        print(f"⚠️ Firebase Init Warning: {e}")

db = firestore.client()

# --- REQUEST SCHEMAS ---
class EscrowCreate(BaseModel):
    item_name: str
    price: float
    tracking_number: str
    seller_uid: str
    category: str = "Online Business"

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
    print(f"❌ Validation Error: {exc.errors()}")
    return JSONResponse(
        status_code=422,
        content={"status": "INVALID_INPUT", "message": str(exc.errors())}
    )

# --- CORS MIDDLEWARE (RELAXED FOR LOCAL TESTING) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# MIDDLEWARE TO LOG EVERY REQUEST
@app.middleware("http")
async def log_requests(request: Request, call_next):
    print(f"📥 Incoming: {request.method} {request.url.path}")
    response = await call_next(request)
    print(f"📤 Outgoing: Status {response.status_code}")
    return response

GENKIT_URL: str = os.environ.get("GENKIT_URL", "http://127.0.0.1:3400")

@app.get("/health")
async def health_check() -> Dict[str, str]:
    return {"status": "ok"}

@app.post("/api/escrow/create")
async def create_escrow(request: EscrowCreate) -> Dict[str, str]:
    print(f"🛠️ Creating Escrow for {request.item_name} (RM {request.price})")
    escrow_id = str(uuid.uuid4())[:8]
    escrow_data = {
        "item": request.item_name,
        "price": request.price,
        "tracking_number": request.tracking_number,
        "seller_uid": request.seller_uid,
        "category": request.category,
        "status": escrow_manager.EscrowState.PENDING,
        "ai_verified": False,
        "payout_executed": False,
        "receipt_hash": None,
        "logs": ["Session Created", f"Category: {request.category}", f"Tracking: {request.tracking_number}"],
        "created_at": firestore.SERVER_TIMESTAMP
    }
    
    try:
        db.collection("escrows").document(escrow_id).set(escrow_data)
        print(f"✅ Escrow {escrow_id} saved to Firestore.")
    except Exception as e:
        print(f"❌ Firestore Error: {e}")
        raise HTTPException(status_code=500, detail="Database write failed.")
        
    return {"escrow_id": escrow_id, "status": escrow_manager.EscrowState.PENDING}

@app.post("/api/escrow/upload-receipt/{escrow_id}")
async def upload_receipt(
    escrow_id: str, 
    background_tasks: BackgroundTasks, 
    file: UploadFile = File(...)
) -> Dict[str, Any]:
    doc_ref = db.collection("escrows").document(escrow_id)
    doc = doc_ref.get()
    
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Escrow session not found.")

    data = doc.to_dict()
    
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are supported.")

    # 1. Independent SHA-256 Hashing
    contents = await file.read()
    file_hash = hashlib.sha256(contents).hexdigest()
    doc_ref.update({
        "receipt_hash": file_hash,
        "logs": firestore.ArrayUnion([f"FINGERPRINT GEN: {file_hash[:16]}..."])
    })
    
    base64_image = f"data:{file.content_type};base64,{base64.b64encode(contents).decode('utf-8')}"
    
    # 2. Bridge to AI
    try:
        async with httpx.AsyncClient() as client:
            genkit_resp = await client.post(
                f"{GENKIT_URL}/analyzeReceipt",
                json={
                    "data": {
                        "transactionId": escrow_id,
                        "expectedAmount": str(data["price"]),
                        "receiptImageBase64": base64_image
                    }
                },
                timeout=30.0
            )
            analysis = genkit_resp.json().get("result", {})
    except Exception as e:
        print(f"⚠️ AI Bridge Failed: {e}")
        # SECURITY FIX: Do NOT approve on failure. Move to Disputed.
        doc_ref.update({
            "ai_verified": False,
            "rejection_type": "ENGINE_TIMEOUT",
            "rejection_reason": "AI Security Engine failed to respond. Session locked for safety.",
            "logs": firestore.ArrayUnion([f"⚠️ SECURITY: AI Analysis Timed Out. Transaction Halted."])
        })
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.DISPUTED)
        return {"status": "HALTED", "message": "Security engine timeout."}

    is_authentic = analysis.get("is_authentic", False)
    confidence = analysis.get("confidence_score", 0)
    reasoning = analysis.get("reasoning", "Unknown reason")
    rejection_type = analysis.get("rejection_type", "NONE")

    # STRICT SUCCESS CRITERIA
    if is_authentic and confidence >= 85 and rejection_type == "NONE":
        doc_ref.update({
            "ai_verified": True,
            "logs": firestore.ArrayUnion([f"AI VERDICT: Authentic ({confidence}%)"])
        })
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.FUNDED)
        background_tasks.add_task(escrow_manager.start_courier_polling, escrow_id, data["tracking_number"])
    else:
        # 🔥 REJECTION LOGIC
        error_msg = f"🚨 AI REJECTED [{rejection_type}]: {reasoning}"
        doc_ref.update({
            "ai_verified": False,
            "rejection_type": rejection_type,
            "rejection_reason": reasoning,
            "logs": firestore.ArrayUnion([error_msg])
        })
        await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.DISPUTED)

    actual_status = "Funded" if (is_authentic and confidence >= 85 and rejection_type == "NONE") else "Disputed"
    return {
        "escrow_id": escrow_id,
        "receipt_hash": file_hash,
        "ai_verdict": analysis,
        "current_status": actual_status
    }

@app.get("/api/escrow/status/{escrow_id}")
async def get_status(escrow_id: str) -> Dict[str, Any]:
    doc = db.collection("escrows").document(escrow_id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Escrow not found.")
    return doc.to_dict()

@app.post("/api/escrow/dispute/{escrow_id}")
async def raise_dispute(escrow_id: str, request: DisputeRequest) -> Dict[str, Any]:
    doc_ref = db.collection("escrows").document(escrow_id)
    escrow_exists = doc_ref.get().exists
    if escrow_exists:
        doc_ref.update({"logs": firestore.ArrayUnion(["DISPUTE: Initializing AI Mediator..."])})

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
                },
                timeout=30.0
            )
            resolution = genkit_resp.json().get("result", {})
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI Mediator bridge failed: {str(e)}")

    if escrow_exists:
        action = resolution.get("actionToTake")
        if action == "REFUND_BUYER":
            await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.DISPUTED)
            doc_ref.update({"logs": firestore.ArrayUnion(["MEDIATOR: Refund approved."])})
        else:
            await escrow_manager.update_escrow_status(escrow_id, escrow_manager.EscrowState.RELEASED)
            doc_ref.update({"logs": firestore.ArrayUnion(["MEDIATOR: Payout released."])})

    return {
        "escrow_id": escrow_id,
        "ai_resolution": resolution
    }

if os.path.exists("ui_build"):
    app.mount("/", StaticFiles(directory="ui_build", html=True), name="ui")

if __name__ == "__main__":
    import uvicorn
    # Use 0.0.0.0 to listen on all interfaces
    uvicorn.run(app, host="0.0.0.0", port=8080)

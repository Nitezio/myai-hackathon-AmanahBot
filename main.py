from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
import ai_agents

app = FastAPI(title="Amanah-Bot EaaS Backend")

# ... existing CORS ...

@app.post("/api/escrow/upload-receipt")
async def upload_receipt(file: UploadFile = File(...)):
    """
    Endpoint for buyers to upload bank receipts.
    Integrates Gemini AI for forensics.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are supported.")
    
    contents = await file.read()
    
    # Call the AI Agent (Phase 2)
    analysis = await ai_agents.analyze_receipt(contents)
    
    if "error" in analysis:
        # Fallback for hackathon if API key is missing
        return {
            "status": "AI_OFFLINE",
            "message": "AI Analysis was not performed. Check API Key.",
            "analysis_debug": analysis
        }

    # Verify extracted data with Mock Bank API (Phase 2 Integration)
    extracted = analysis.get("extracted_data", {})
    bank_verification = await verify_payment(
        transaction_id=extracted.get("transaction_id", "UNKNOWN"),
        amount=extracted.get("amount", 0.0)
    )

    return {
        "ai_verdict": analysis,
        "bank_status": bank_verification,
        "is_funded": analysis.get("is_authentic") and bank_verification.get("funds_secured")
    }

# Mock Bank Webhook (as defined before)
@app.post("/api/bank/verify")
async def verify_payment(transaction_id: str, amount: float):
    # Simulated verification logic
    return {
        "status": "Verified",
        "funds_secured": True,
        "transaction_id": transaction_id,
        "amount": amount,
        "timestamp": "2026-04-20T17:20:00Z"
    }

# Mock Courier Webhook
@app.get("/api/courier/track/{tracking_number}")
async def track_courier(tracking_number: str):
    # Hackathon Trick: Return status based on last digit
    # 1=Pending, 2=In Transit, 3=Delivered
    last_digit = tracking_number[-1]
    
    status_map = {
        "1": "Pending",
        "2": "In Transit",
        "3": "Delivered"
    }
    
    status = status_map.get(last_digit, "Unknown")
    
    return {
        "tracking_number": tracking_number,
        "status": status,
        "courier": "PosLaju/J&T"
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)

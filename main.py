from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI(title="Amanah-Bot EaaS Backend")

# Configure CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For hackathon; update to specific URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Amanah-Bot EaaS Backend is running."}

@app.get("/health")
async def health_check():
    return {"status": "ok"}

# Mock Bank Webhook
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

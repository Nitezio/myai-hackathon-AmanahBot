import asyncio
import httpx
import logging
import json
import time

# Structured Logging Setup
class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": time.time(),
            "level": record.levelname,
            "message": record.getMessage(),
            "escrow_id": getattr(record, "escrow_id", "N/A"),
            "agent_action": getattr(record, "agent_action", False)
        }
        return json.dumps(log_record)

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logger = logging.getLogger("AmanahBot-Orchestrator")
logger.addHandler(handler)
logger.setLevel(logging.INFO)
logger.propagate = False # Prevent double logging

class EscrowState:
    PENDING = "Payment_Pending"
    FUNDED = "Funded"
    IN_TRANSIT = "In_Transit"
    DELIVERED = "Delivered"
    RELEASED = "Released"
    DISPUTED = "Disputed"

# In-memory storage
escrow_db = {
    "TX-DEMO-123": {
        "item": "Jordan 1 Retro High",
        "price": 450.00,
        "tracking_number": "JNT-999",
        "status": EscrowState.PENDING,
        "ai_verified": False,
        "payout_executed": False
    },
    "TX-DEMO-999": {
        "item": "Test Item",
        "price": 50.00,
        "tracking_number": "POS-888",
        "status": EscrowState.PENDING,
        "ai_verified": False,
        "payout_executed": False
    }
}

async def update_escrow_status(escrow_id: str, new_status: str):
    """Updates the state and logs the transition in structured JSON."""
    if escrow_id in escrow_db:
        old_status = escrow_db[escrow_id]["status"]
        if old_status == new_status:
            return True
            
        escrow_db[escrow_id]["status"] = new_status
        logger.info(
            f"State Transition: {old_status} -> {new_status}", 
            extra={"escrow_id": escrow_id, "agent_action": True}
        )
        return True
    return False


async def start_courier_polling(escrow_id: str, tracking_number: str, backend_url: str = "http://localhost:8000"):
    """
    The Agentic Polling Loop.
    This runs autonomously until the item is delivered.
    """
    logger.info(f"Starting autonomous polling for Escrow {escrow_id} [Tracking: {tracking_number}]")
    
    while True:
        try:
            async with httpx.AsyncClient() as client:
                # Poll the Mock Courier API
                response = await client.get(f"{backend_url}/api/courier/track/{tracking_number}")
                data = response.json()
                
                status = data.get("status")
                
                if status == "In Transit":
                    await update_escrow_status(escrow_id, EscrowState.IN_TRANSIT)
                
                elif status == "Delivered":
                    await update_escrow_status(escrow_id, EscrowState.DELIVERED)
                    # AGENTIC ACTION: Autonomous Fund Release
                    await release_funds_autonomously(escrow_id)
                    break # Exit loop once delivered and released
                
        except Exception as e:
            logger.error(f"Polling error for {escrow_id}: {str(e)}")
            
        # Wait for 10 seconds before next poll (Shortened for demo purposes)
        await asyncio.sleep(10)

async def release_funds_autonomously(escrow_id: str):
    """
    The 'Action' in Agentic AI. 
    ZERO-TRUST POLICY: Unlocks the vault ONLY if AI has verified the payment 
    AND physical delivery is confirmed.
    """
    if not escrow_db[escrow_id].get("ai_verified", False):
        logger.error(f"ZERO-TRUST VIOLATION: Attempt to release funds for {escrow_id} without AI verification!")
        await update_escrow_status(escrow_id, EscrowState.DISPUTED)
        return

    logger.info(f"!!! AGENTIC ACTION: Unlocking funds for Escrow {escrow_id} !!!")
    await update_escrow_status(escrow_id, EscrowState.RELEASED)
    # Here we would call the Bank Payout API in production
    escrow_db[escrow_id]["payout_executed"] = True

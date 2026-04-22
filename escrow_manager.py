import asyncio
import httpx
import logging

# Setup logging for autonomous actions
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("AmanahBot-Orchestrator")

class EscrowState:
    PENDING = "Payment_Pending"
    FUNDED = "Funded"
    IN_TRANSIT = "In_Transit"
    DELIVERED = "Delivered"
    RELEASED = "Released"
    DISPUTED = "Disputed"

# In-memory storage for hackathon demo
# In production, this would be Firestore/PostgreSQL
escrow_db = {}

async def update_escrow_status(escrow_id: str, new_status: str):
    """
    Updates the state and logs the transition.
    """
    if escrow_id in escrow_db:
        old_status = escrow_db[escrow_id]["status"]
        escrow_db[escrow_id]["status"] = new_status
        logger.info(f"Escrow {escrow_id}: {old_status} -> {new_status}")
        return True
    return False

async def start_courier_polling(escrow_id: str, tracking_number: str, backend_url: str = "http://localhost:8080"):
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
    Unlocks the vault once the physical condition (Delivery) is met.
    """
    logger.info(f"!!! AGENTIC ACTION: Unlocking funds for Escrow {escrow_id} !!!")
    await update_escrow_status(escrow_id, EscrowState.RELEASED)
    # Here we would call the Bank Payout API in production
    escrow_db[escrow_id]["payout_executed"] = True

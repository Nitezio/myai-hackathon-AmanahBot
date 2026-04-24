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
logger.propagate = False 

class EscrowState:
    PENDING = "Payment_Pending"
    FUNDED = "Funded"
    IN_TRANSIT = "In_Transit"
    DELIVERED = "Delivered"
    RELEASED = "Released"
    DISPUTED = "Disputed"

# In-memory storage
escrow_db = {}

async def update_escrow_status(escrow_id: str, new_status: str):
    """Updates the state and appends to the internal activity log."""
    if escrow_id in escrow_db:
        old_status = escrow_db[escrow_id]["status"]
        escrow_db[escrow_id]["status"] = new_status
        
        # Add to the Log that appears in the UI
        timestamp = time.strftime("%H:%M:%S")
        log_msg = f"[{timestamp}] AGENT: {old_status} -> {new_status}"
        escrow_db[escrow_id].setdefault("logs", []).append(log_msg)
        
        logger.info(
            f"State Transition: {old_status} -> {new_status}", 
            extra={"escrow_id": escrow_id, "agent_action": True}
        )
        return True
    return False

async def start_courier_polling(escrow_id: str, tracking_number: str):
    """
    The Agentic Polling Loop with Smart Demo Progression.
    """
    backend_url = "http://127.0.0.1:8080"
    
    # LOG START
    escrow_db[escrow_id].setdefault("logs", []).append(f"AGENT: Started autonomous tracking for {tracking_number}")
    
    # DEMO LOGIC: If tracking ends in 3, we simulate a 3-stage progression
    # funded -> in_transit -> delivered -> released
    is_demo = tracking_number.endswith("3")
    
    attempts = 0
    while attempts < 30:
        try:
            # 1. Simulate the 'In Transit' scan after 4 seconds
            if is_demo and attempts == 1:
                await update_escrow_status(escrow_id, EscrowState.IN_TRANSIT)
                escrow_db[escrow_id]["logs"].append("AGENT: Courier picked up parcel at Hub.")
            
            # 2. Simulate the 'Delivered' scan after 8 seconds
            elif is_demo and attempts == 3:
                await update_escrow_status(escrow_id, EscrowState.DELIVERED)
                escrow_db[escrow_id]["logs"].append("AGENT: Courier confirmed delivery at doorstep.")
                # TRIGGER AUTO PAYOUT
                await release_funds_autonomously(escrow_id)
                break
            
            # 3. Standard non-demo logic (real-time polling)
            elif not is_demo:
                async with httpx.AsyncClient() as client:
                    response = await client.get(f"{backend_url}/api/courier/track/{tracking_number}", timeout=5.0)
                    data = response.json()
                    status = data.get("status")
                    
                    if status == "In Transit" and escrow_db[escrow_id]["status"] != EscrowState.IN_TRANSIT:
                        await update_escrow_status(escrow_id, EscrowState.IN_TRANSIT)
                    elif status == "Delivered":
                        await update_escrow_status(escrow_id, EscrowState.DELIVERED)
                        await release_funds_autonomously(escrow_id)
                        break 
        except Exception as e:
            logger.error(f"POLLING ERROR: {str(e)}", extra={"escrow_id": escrow_id})
            
        attempts += 1
        await asyncio.sleep(3) # Polling cycle speed

async def release_funds_autonomously(escrow_id: str):
    """Unlocks the vault autonomously."""
    if not escrow_db[escrow_id].get("ai_verified", False):
        log_err = "AGENT: ZERO-TRUST BLOCK! AI verification not found."
        escrow_db[escrow_id].setdefault("logs", []).append(log_err)
        await update_escrow_status(escrow_id, EscrowState.DISPUTED)
        return

    escrow_db[escrow_id]["logs"].append("AGENT: All conditions met. Unlocking Escrow Vault...")
    await update_escrow_status(escrow_id, EscrowState.RELEASED)
    escrow_db[escrow_id]["payout_executed"] = True
    escrow_db[escrow_id]["logs"].append("AGENT: Payout successful. Transaction finalized.")

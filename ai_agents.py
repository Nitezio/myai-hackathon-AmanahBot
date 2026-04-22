import google.generativeai as genai
import os
from PIL import Image
import io
import json

# Initialize Gemini
# The API Key should be set in environment variables
API_KEY = os.environ.get("GEMINI_API_KEY")
if API_KEY:
    genai.configure(api_key=API_KEY)

RECEIPT_FORENSIC_PROMPT = """
You are a specialized Forensic Financial Auditor for Amanah-Bot. 
Your task is to analyze the provided bank transfer receipt (DuitNow/Bank Transfer) and determine its authenticity.

### INSTRUCTIONS:
1. **Data Extraction**: Extract the Transaction ID, Amount (RM), Date/Time, and Receiver Name.
2. **Forgery Detection**: Look for artifacts of manipulation:
    - Font inconsistencies (different weights or styles in numerical fields).
    - Pixel blurring or "noise" specifically around the Amount or Transaction ID.
    - Alignment issues in text blocks.
    - Inconsistent date formats or overlapping text.
3. **Verdict**: Provide a confidence score (0-100) on whether the receipt is authentic.

### OUTPUT FORMAT (Strict JSON):
{
    "is_authentic": boolean,
    "confidence_score": number,
    "extracted_data": {
        "transaction_id": "string",
        "amount": number,
        "date": "string",
        "receiver_name": "string"
    },
    "forensic_notes": "string explaining any detected anomalies or confirmation of authenticity"
}
"""

async def analyze_receipt(image_bytes: bytes):
    """
    Analyzes a receipt image using Gemini 1.5 Pro.
    """
    if not API_KEY:
        return {"error": "GEMINI_API_KEY not configured. AI Analysis skipped."}

    try:
        model = genai.GenerativeModel('gemini-1.5-pro')
        
        # Convert bytes to PIL Image
        image = Image.open(io.BytesIO(image_bytes))
        
        # Call Gemini
        response = model.generate_content([RECEIPT_FORENSIC_PROMPT, image])
        
        # Attempt to parse JSON from response
        # Note: In production, use more robust JSON cleaning
        result_text = response.text.replace('```json', '').replace('```', '').strip()
        return json.loads(result_text)
        
    except Exception as e:
        return {"error": str(e)}

def get_arbitration_prompt(chat_logs: str, evidence_description: str):
    """
    Returns a prompt for the NLP Dispute Mediator.
    """
    return f"""
    You are the Amanah-Bot AI Mediator. A dispute has been raised.
    
    ### CONTEXT:
    Chat Logs: {chat_logs}
    Buyer Evidence: {evidence_description}
    
    ### TASK:
    Analyze based on Malaysian Consumer Protection laws:
    1. Has the item been delivered (check logs)?
    2. Does the evidence support a 'Significantly Not As Described' claim?
    3. Make a final decision: PAYOUT TO SELLER or REFUND TO BUYER.
    
    OUTPUT: A clear justification and the final decision.
    """

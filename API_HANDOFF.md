# Amanah-Bot API Handoff & Integration Spec

This document details the interface between the **Flutter Frontend** and the **FastAPI Gateway**.

---

## 🔗 Base URL
*   **Production:** (TBD - Cloud Run)
*   **Local (FastAPI):** `http://localhost:8080`
*   **Local (Genkit):** `http://localhost:3400` (Internal only)

---

## 📝 Escrow Management Endpoints

### 1. Initialize Escrow
`POST /api/escrow/create`
*   **Purpose:** Creates a new pending escrow session.
*   **Input (JSON):**
    ```json
    {
      "item_name": "MacBook Air M2",
      "price": 3500.00,
      "tracking_number": "JNT-12345"
    }
    ```
*   **Output (JSON):**
    ```json
    {
      "escrow_id": "8a2b3c4d",
      "status": "Payment_Pending"
    }
    ```

### 2. Upload Receipt & Trigger AI Forensics
`POST /api/escrow/upload-receipt/{escrow_id}`
*   **Purpose:** Accepts a receipt image, bridges it to Genkit for analysis, and updates state.
*   **Input (Multipart Form Data):**
    *   `file`: The receipt image file (JPG/PNG).
*   **Output (JSON):**
    ```json
    {
      "escrow_id": "8a2b3c4d",
      "ai_verdict": {
        "is_receipt": true,
        "is_authentic": true,
        "confidence_score": 95,
        "reasoning": "Receipt matches expected amount and shows no pixel manipulation."
      },
      "current_status": "Funded"
    }
    ```

### 3. Get Real-Time Status
`GET /api/escrow/status/{escrow_id}`
*   **Purpose:** Returns the current state of the escrow.
*   **States:** `Payment_Pending`, `Funded`, `In_Transit`, `Delivered`, `Released`, `Disputed`.
*   **Output (JSON):**
    ```json
    {
      "item": "MacBook Air M2",
      "price": 3500.00,
      "tracking_number": "JNT-12345",
      "status": "In_Transit",
      "ai_verified": true,
      "payout_executed": false
    }
    ```

### 4. Raise Dispute (AI Mediator)
`POST /api/escrow/dispute/{escrow_id}`
*   **Purpose:** Triggers the Genkit NLP Mediator to resolve conflict.
*   **Input (JSON):**
    ```json
    {
      "buyer_complaint": "Item arrived damaged.",
      "seller_response": "Item was packed securely.",
      "chat_logs": "..."
    }
    ```
*   **Output (JSON):**
    ```json
    {
      "escrow_id": "8a2b3c4d",
      "ai_resolution": {
        "winner": "BUYER",
        "reasoning": "Evidence supports shipping damage; seller insurance should cover.",
        "actionToTake": "REFUND_BUYER"
      },
      "new_status": "Disputed"
    }
    ```

---

## 🏗️ Local Development Steps
1.  **Terminal 1 (Genkit):** `npm run start`
2.  **Terminal 2 (FastAPI):** `python main.py`
3.  **Terminal 3 (Flutter):** `cd amanah_ui && flutter run`

*Note: For Android Emulators, change `localhost` in `ApiService.dart` to `10.0.2.2`.*

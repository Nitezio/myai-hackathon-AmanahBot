# Amanah-Bot: Agentic AI Escrow-as-a-Service (EaaS)

**Amanah-Bot** is a Plug-and-Play, Agentic AI Escrow infrastructure designed to eliminate non-delivery and fake payment scams in social commerce. Built for the **Project 2030 MyAI Future Hackathon (Track 5: FinTech & Security)**.

---

## 📌 Project Overview
Amanah-Bot elevates escrow from a standalone app to a scalable **B2B2C infrastructure**. It provides a "Secure Checkout Link" that sellers can share via WhatsApp, Instagram, or Telegram. The system autonomously holds funds, detects forensic fraud in receipts using **Gemini 2.5 Flash Lite**, and releases payments based on real-time courier API confirmations.

### 🇲🇾 Malaysia Context & Problem
*   **Social Commerce Fraud:** RM50-200 micro-scams are rampant on non-secure platforms.
*   **Fake DuitNow Receipts:** Sellers are frequently cheated by digitally altered transfer screenshots.
*   **Zero-Trust Barrier:** Strangers are afraid to transact without a trusted intermediary.

---

## ✨ Core Features (Verified)
1.  **Hybrid AI Hub:** A bridged dual-engine (FastAPI + Genkit V1) that isolates high-stakes AI reasoning from core state management.
2.  **Multimodal Forensics:** Deep visual analysis of receipt pixels, fonts, and metadata to catch manipulated screenshots.
3.  **Agentic Polling:** Non-blocking background loops that autonomously monitor PosLaju/J&T status via simulated webhooks.
4.  **Zero-Trust Vault:** Automated fund release triggered ONLY by delivery confirmation AND verified AI forensics.
5.  **AI Mediator:** Unbiased NLP arbitrator that resolves disputes in seconds using Malaysian consumer protection context.
6.  **Structured Observability:** Professional JSON logging of every agentic decision for audit transparency.

---

## 📐 Technical Architecture
*   **Gateway (Python/FastAPI):** The central state machine. Manages the escrow database, mock APIs, and non-blocking background tasks.
*   **AI Engine (Node.js/Genkit):** The specialized intelligence layer. Executes complex multimodal flows for receipt checking and dispute mediation.
*   **Bridging:** The Gateway bridges binary image data to the AI Engine via a secure internal network using Base64 encoding.
*   **Deployment:** 100% Cloud-Native; Dockerized and ready for Google Cloud Run multi-service deployment.

---

## 🛡️ Security & Zero-Trust Protocol
We implemented three layers of "Enterprise-Grade" security to satisfy the hackathon's strictest criteria:
*   **Intelligent Thresholds:** The vault refuses to fund any transaction where the AI's confidence score is **below 85%**.
*   **Prompt Injection Lockdown:** System instructions for Gemini are hardened with mandates to ignore user-provided text overrides (e.g., "ignore previous rules").
*   **Error Masking:** Production exception handlers mask internal IDs and stack traces, returning sanitized JSON to prevent data leakage.

---

## 📋 Official Master Team Checklist

### **1. Project Manager & Pitch Strategist**
*Focus: Strategic alignment, revenue model, and securing the 30 marks for Innovation, Impact, and Pitch.*

*   **[ ] Task 1.1: Official Registration (URGENT)**
    *   Submit the Google Form by **Tonight 11:59 PM**.
    *   Ensure all team member GitHub profiles are correctly linked.
*   **[ ] Task 1.2: 15-Slide Pitch Deck (PDF)**
    *   **The Problem:** Focus on RM50-200 social commerce fraud in Malaysia (WhatsApp/Instagram niche).
    *   **The Pivot:** Explain "Escrow-as-a-Service" (EaaS) as a plug-and-play widget for any platform.
    *   **The Business Model:** Detail the 1.5% micro-fee revenue structure.
    *   **National Impact:** Align with Malaysia Madani / MyDIGITAL blueprints.
*   **[ ] Task 1.3: 3-Minute Video Demo**
    *   Script a flow: Link Generation $\rightarrow$ AI Receipt Check $\rightarrow$ Agentic Polling $\rightarrow$ Auto-Release.
    *   Record a clean walkthrough of the working prototype.
*   **[ ] Task 1.4: Final Portal Submission**
    *   Finalize: GitHub URL, Cloud Run URL, Video Link, and Deck PDF.

---

### **2. Frontend Architect (Flutter Web)**
*Focus: 10 marks for UI/UX. Currently the project's critical path (0% done).*

*   **[ ] Task 2.1: Flutter Web Initialization**
    *   Create a responsive project optimized for embedded mobile browsers (WhatsApp/Instagram).
*   **[ ] Task 2.2: The "Secure Checkout" Screen (`/pay/{id}`)**
    *   Build a sleek UI for item details and a FileUpload widget for receipts.
    *   **The "Wow" Feature:** Create a status bar that displays the AI's "Reasoning" string in real-time.
*   **[ ] Task 2.3: Seller dashboard**
    *   Simple interface to input item details and generate shareable escrow links.
*   **[ ] Task 2.4: Dispute Resolution Interface**
    *   UI for evidence upload and viewing the "AI Mediator" final verdict.
*   **[ ] Task 2.5: Backend Integration**
    *   Connect the UI to the Python Gateway (Port 8080) using the `API_HANDOFF.md` specifications.

---

### **3. Backend & Cloud Lead**
*Focus: Infrastructure, Security, and Code Quality. Status: 90% done.*

*   **[x] Task 3.1: Hybrid Engine Bridge** (FastAPI bridged to Genkit Node.js).
*   **[x] Task 3.2: Multi-Service Containerization** (Both Dockerfiles ready and hardened).
*   **[x] Task 3.3: Deployment Automation** (Created `deploy_to_gcp.sh`).
*   **[x] Task 3.4: Code Polish & Type Safety** (Added Pydantic models and full docstrings).
*   **[x] Task 3.5: API Documentation** (Created `API_HANDOFF.md`).
*   **[ ] Task 3.6: Cloud Run Deployment (BLOCKER: Credits)**
    *   Deploy both services to GCP once credits are redeemed.
    *   Provision `GEMINI_API_KEY` in **GCP Secret Manager** (Mandatory for security marks).
*   **[ ] Task 3.7: Cross-Service Cloud Link**
    *   Update the Python service `GENKIT_URL` with the live Cloud Run URL of the AI server.

---

### **4. Agentic Workflow & Security Lead**
*Focus: 25 marks for AI Implementation. Status: 100% done.*

*   **[x] Task 4.1: Multimodal Forensic Flows** (Gemini 2.5 Flash Lite receipt checks).
*   **[x] Task 4.2: NLP Dispute Mediator** (Unbiased legal arbitration flow).
*   **[x] Task 4.3: Zero-Trust Guardrails** (Double-condition payout: AI Verified + Delivered).
*   **[x] Task 4.4: Prompt Injection Lockdown** (Hardened system mandates).
*   **[x] Task 4.5: Reasoning & Audit Logs** (AI now outputs step-by-step thinking).
*   **[x] Task 4.6: Autonomous Proof Run** (Captured logs of the agent acting alone).
*   **[x] Task 4.7: Intelligent Thresholds**
    *   Final logic update to auto-dispute transactions where AI confidence is `< 85%`.

---

## 🛠 Setup & Local Development
### 1. Prerequisites
- **Python 3.10+** and **Node.js 20+**.
- Set Gemini Key: `$env:GEMINI_API_KEY="your_key"`

### 2. Start the Engine (Node.js)
```bash
cd myai-hackathon-AmanahBot
npm install
npx tsx src/index.ts  # Runs Port 3400
```

### 3. Start the Gateway (Python)
```bash
# In a new terminal
pip install -r requirements.txt
python main.py  # Runs Port 8080
```

### 4. Technical Documentation
- **API Spec:** Refer to `API_HANDOFF.md` for endpoint details.
- **Deployment:** Refer to `deploy_to_gcp.sh` for Cloud Run automation.

---

## 📝 AI Declaration & Compliance
This project explicitly utilizes the **Google AI Ecosystem Stack** for its core intelligence.

*   **Intelligence:** **Gemini 2.5 Flash Lite** (Forensics & Arbitration).
*   **Orchestration:** **Firebase Genkit V1** (Agentic Flows).
*   **Development:** **Gemini CLI** and **GitHub Copilot** (Architecture & Documentation).

**Verification:** All AI-generated code has been rigorously audited and hardened by human team leads.

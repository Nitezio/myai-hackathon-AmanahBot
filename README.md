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

## 📋 Role-Based Master Checklist

### **Frontend Architect (Flutter Web)** - *IN PROGRESS*
- [ ] Initialize responsive Flutter Web project (Mobile-Optimized).
- [ ] Build **Checkout Link Screen** (`/pay/{id}`) with FileUpload.
- [ ] Implement **Live Reasoning Bar** (Displays the AI's "Chain of Thought" string).
- [ ] Connect to Backend via `API_HANDOFF.md` specs.

### **Backend & Cloud Lead (YOU)** - *100% DONE*
- [x] Build Hybrid Foundation (FastAPI + Genkit Bridge).
- [x] Implement Mock APIs & Health Checks.
- [x] Dockerize both services (Multi-Container ready).
- [x] Polish Code: Type hints, Pydantic models, and production Docstrings.
- [x] **Verified:** End-to-End Success Path & Bridge Latency.

### **Agentic Workflow & Security Lead (YOU)** - *100% DONE*
- [x] Engineer Multimodal Forensic Flow (Gemini 2.5 Flash Lite).
- [x] Engineer NLP Arbitration Flow (AI Mediator).
- [x] Implement Zero-Trust double-condition payout logic.
- [x] Harden prompts against instruction-override attacks.
- [x] Implement 85% Confidence Threshold Fail-Safe.

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

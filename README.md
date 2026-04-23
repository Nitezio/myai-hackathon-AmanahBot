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

## ✨ Completed Features (Verified)
1.  **Hybrid AI Hub:** A bridged dual-engine (FastAPI + Genkit V1) for specialized reasoning.
2.  **Multimodal Forensics:** AI analysis of receipt pixels, fonts, and metadata to catch forgeries.
3.  **Agentic Polling:** Non-blocking background loops that autonomously monitor courier status.
4.  **Zero-Trust Vault:** Automatic fund release triggered ONLY by courier "Delivered" status.
5.  **AI Mediator:** Unbiased NLP arbitrator for rapid dispute resolution.
6.  **Structured Observability:** Real-time JSON logging of all agentic decisions.

---

## 📐 Technical Architecture
*   **Gateway (Python/FastAPI):** Manages escrow state, mocks (Bank/Courier), and background tasks.
*   **AI Engine (Node.js/Genkit):** Executes complex multimodal and NLP reasoning flows.
*   **Bridging:** The Gateway bridges data to the AI Engine via a secure internal local network.
*   **Deployment:** 100% Cloud-Native; Dockerized and ready for Google Cloud Run.

---

## 📋 Role-Based Master Checklist

### **Frontend Architect (Flutter Web)** - *IN PROGRESS*
- [ ] Initialize responsive Flutter Web project (High-Contrast/Mobile-Optimized).
- [ ] Build **Checkout Link Screen** (`/pay/{id}`) with FileUpload for receipts.
- [ ] Build **Seller Dashboard** to generate links and monitor active states.
- [ ] Connect to Backend using `API_HANDOFF.md` specs.

### **Backend & Cloud Lead (YOU)** - *95% DONE*
- [x] Build Hybrid Foundation (FastAPI + Genkit Bridge).
- [x] Implement Mock APIs & Health Checks.
- [x] Dockerize both services (Multi-Container ready).
- [x] Polish Code: Type hints, Pydantic models, and Docstrings.
- [ ] **Next:** Deploy to Cloud Run (Waiting for credits).

### **Agentic Workflow & Security Lead (YOU)** - *100% DONE*
- [x] Engineer Multimodal Forensic Flow (Receipt check).
- [x] Engineer NLP Arbitration Flow (Dispute mediator).
- [x] Implement Zero-Trust double-condition payout logic.
- [x] Harden prompts against instruction-override attacks.
- [x] Implement structured reasoning console logs.

### **Project Manager & Pitch Strategist** - *PENDING*
- [ ] Submit official registration (Deadline: Tonight 11:59 PM).
- [ ] Draft 15-Slide Pitch Deck (Focus: EaaS Scalability & National Impact).
- [ ] Produce 3-Minute Demo Video (Highlight autonomous logs).

---

## 🛠 Teammate Testing Guide
To test the full "Agentic" loop on your local machine:

### 1. Prerequisites
- Install **Python 3.10+** and **Node.js 20+**.
- Set your Gemini API Key: `$env:GEMINI_API_KEY="your_key"`

### 2. Start the AI Engine (Node.js)
```bash
cd myai-hackathon-AmanahBot
npm install
npx tsx src/index.ts  # Runs on Port 3400
```

### 3. Start the Gateway (Python)
```bash
# In a new terminal
pip install -r requirements.txt
python main.py  # Runs on Port 8080
```

### 4. Perform a Manual Test
Open **[http://localhost:8080/docs](http://localhost:8080/docs)** (Swagger UI):
1.  **Create:** Use `/api/escrow/create` with tracking number ending in `3`.
2.  **Fund:** Use `/api/escrow/upload-receipt/{id}` with any image.
3.  **Observe:** Watch the terminal logs. You will see the agent autonomously poll and release funds!

---

## ✅ Submission Checklist
- [ ] Cloud Run URL (Publicly accessible).
- [ ] GitHub Repo (Public with AI Declaration).
- [ ] 3-Minute Demo Video.
- [ ] 15-Slide Pitch Deck.

---

## 📝 AI Declaration & Compliance
This project strictly adheres to the **Google Project 2030 Hackathon** mandates. 

*   **Intelligence:** **Gemini 2.5 Flash Lite** powers our forensics and legal arbitration.
*   **Orchestration:** **Firebase Genkit V1** handles our complex agentic state transitions.
*   **Development:** **Gemini CLI** and **GitHub Copilot** were utilized for architectural blueprints and rapid documentation.

**Verification:** All AI-generated logic has been hardened and audited for security by the human team leads.

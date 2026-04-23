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

## 🛠 Hackathon Toolstack Compliance
As per the **Project 2030 MyAI Future Hackathon** mandates, this project utilizes the following official developer tools:

| Tool | Purpose in Project |
| :--- | :--- |
| **Google Antigravity** | Our **Agentic IDE**. Used for multi-agent orchestration, "Manager View" reasoning visualization, and Zero-G dynamic UI design. |
| **Android Studio** | The primary environment for **Flutter Web** development, utilized for mobile responsiveness testing and network debugging. |
| **Google Cloud Run** | The production hosting platform, utilizing a multi-container deployment (FastAPI Gateway + Genkit AI Hub). |
| **Google AI Studio** | Used for rapid prompt engineering, multimodal testing, and Gemini API management. |
| **Firebase Genkit** | The core orchestration layer that manages our state machine and autonomous polling loops. |

---

## ✨ Core Features (Verified)
1.  **Hybrid AI Hub:** A bridged dual-engine (FastAPI + Genkit V1) that isolates AI reasoning.
2.  **Multimodal Forensics:** Deep visual analysis of receipt pixels and fonts to catch manipulated screenshots.
3.  **Agentic Polling:** Non-blocking background loops that autonomously monitor PosLaju/J&T status.
4.  **Zero-Trust Vault:** Automated fund release triggered ONLY by delivery confirmation AND verified AI forensics.
5.  **AI Mediator:** Unbiased NLP arbitrator for rapid dispute resolution using Malaysian consumer law context.
6.  **Structured Observability:** Professional JSON logging of every agentic decision.

---

## 📐 Technical Architecture
*   **Gateway (Python/FastAPI):** Manages escrow state, mocks, and background tasks.
*   **AI Engine (Node.js/Genkit):** Executes complex multimodal flows for receipt checking and dispute mediation.
*   **Bridging:** Secure internal Base64 data bridging between services.
*   **Deployment:** 100% Cloud-Native; Dockerized for Google Cloud Run.

---

## 🛡️ Security & Zero-Trust Protocol
*   **Intelligent Thresholds:** Vault refuses to fund any transaction where AI confidence is **below 85%**.
*   **Prompt Injection Lockdown:** Hardened mandates to ignore user-provided text overrides.
*   **Error Masking:** Production exception handlers mask internal IDs to prevent data leakage.

---

## 📋 Official Master Team Checklist

### **1. Project Manager & Pitch Strategist**
*   **[ ] Task 1.1: Official Registration (URGENT)** (Submit Google Form by Tonight 11:59 PM).
*   **[ ] Task 1.2: 15-Slide Pitch Deck (PDF)** (Focus on EaaS model and National Impact).
*   **[ ] Task 1.3: 3-Minute Video Demo** (Record flow: Link → AI Check → Auto-Release).
*   **[ ] Task 1.4: Final Portal Submission** (Finalize all 4 URLs/Links).

### **2. Frontend Architect (Flutter Web)**
*   **[ ] Task 2.1: Flutter Web Initialization** (Mobile-optimized layout setup).
*   **[ ] Task 2.2: Checkout Screen (`/pay/{id}`)** (FileUpload and AI Reasoning Bar).
*   **[ ] Task 2.3: Seller Dashboard** (Link Generator and Escrow Monitor).
*   **[ ] Task 2.4: Backend Integration** (Connect to Ports 8080 and 3400).

### **3. Backend & Cloud Lead**
*   **[x] Task 3.1: Hybrid Engine Bridge** (Verified Python ↔ Node.js communication).
*   **[x] Task 3.2: Multi-Service Containerization** (Both Dockerfiles ready).
*   **[x] Task 3.3: Deployment Automation** (Created `deploy_to_gcp.sh`).
*   **[x] Task 3.4: Code Polish & Type Safety** (Pydantic models and full docstrings).

### **4. Agentic Workflow & Security Lead**
*   **[x] Task 4.1: Multimodal Forensic Flows** (Gemini 2.5 Flash Lite receipt check).
*   **[x] Task 4.2: NLP Dispute Mediator** (Unbiased legal arbitration).
*   **[x] Task 4.3: Zero-Trust Guardrails** (AI Verified + Delivered condition).
*   **[x] Task 4.4: Prompt Injection Lockdown** (Hardened mandates).

---

## 🛠 Setup & Local Development
1. Clone the repo and install dependencies (`npm install`, `pip install -r requirements.txt`).
2. Set Gemini Key: `$env:GEMINI_API_KEY="your_key"`
3. Start Node.js: `npx tsx src/index.ts` (Port 3400)
4. Start Python: `python main.py` (Port 8080)
5. Refer to `API_HANDOFF.md` for endpoint specifications.

---

## 📝 AI Declaration & Compliance
Amanah-Bot is built from the ground up using the **Google AI Ecosystem Stack**. This project transitions from simple "Chat" models to complex **Agentic AI** capable of autonomous real-world action.

*   **Intelligence:** **Gemini 2.5 Flash Lite** powers our high-intensity forensic vision and arbitration.
*   **Orchestration:** **Firebase Genkit V1** handles our complex agentic flows and state transitions.
*   **Development:** **Gemini CLI** and **GitHub Copilot** were utilized for architecture and documentation.

**Verification:** 100% of AI-generated logic has been audited for security and Zero-Trust compliance by the human team leads.

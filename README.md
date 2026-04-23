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
3.  **Digital Fingerprinting:** Generates unique **SHA-256 hashes** for every uploaded receipt to prevent duplicate submission fraud.
4.  **Agentic Polling:** Non-blocking background loops that autonomously monitor PosLaju/J&T status.
5.  **Zero-Trust Vault:** Automated fund release triggered ONLY by delivery confirmation AND verified AI forensics.
6.  **AI Mediator:** Unbiased NLP arbitrator for rapid dispute resolution using Malaysian consumer law context.
7.  **Structured Observability:** Professional JSON logging of every agentic decision.

---

## 📐 Technical Architecture & Data Flow
*   **Gateway (Python/FastAPI):** Manages the primary escrow state machine and serves the API for the Flutter Frontend.
*   **AI Engine (Node.js/Genkit):** Executes complex multimodal reasoning using **Gemini 2.5 Flash Lite**.
*   **Data Bridge:** Binary image data is captured by the Gateway, converted to **Base64**, and bridged to the AI Engine.
*   **Internal Security:** The AI Engine performs a SHA-256 pre-check and enforces an **85% confidence threshold** before permitting the Gateway to update the escrow state.
*   **Deployment:** Dockerized for multi-container orchestration on Google Cloud Run.

---

## 🛡️ Security & Zero-Trust Protocol
*   **Intelligent Thresholds:** Vault refuses to fund any transaction where AI confidence is **below 85%**.
*   **Prompt Injection Lockdown:** Hardened mandates to ignore user-provided text overrides.
*   **Error Masking:** Production exception handlers mask internal IDs to prevent data leakage.

---

## 📋 Official Master Team Checklist

### **1. Project Manager & Pitch Strategist**
*   **[ ] Task 1.1: Official Registration (URGENT)**
    *   Submit the Google Form by **Tonight 11:59 PM**.
    *   Ensure all team member GitHub profiles are correctly linked.
*   **[ ] Task 1.2: 15-Slide Pitch Deck (PDF)**
    *   **The Problem:** Focus on RM50-200 social commerce fraud in Malaysia.
    *   **The Pivot:** Explain "Escrow-as-a-Service" (EaaS) as a plug-and-play widget.
    *   **The Business Model:** Detail the 1.5% micro-fee revenue structure.
    *   **National Impact:** Align with Malaysia Madani / MyDIGITAL blueprints.
*   **[ ] Task 1.3: 3-Minute Video Demo**
    *   Script a flow: Link Generation $\rightarrow$ AI Receipt Check $\rightarrow$ Agentic Polling $\rightarrow$ Auto-Release.
    *   Record a clean walkthrough of the working prototype.
*   **[ ] Task 1.4: Final Portal Submission**
    *   Finalize: GitHub URL, Cloud Run URL, Video Link, and Deck PDF.

---

### **2. Frontend Architect (Flutter Web)**
*   **[ ] Task 2.1: Flutter Web Initialization**
    *   Create a responsive project optimized for mobile browsers (WhatsApp/Instagram).
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
*   **[x] Task 3.1: Hybrid Engine Bridge** (Verified Python ↔ Node.js communication).
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
*   **[x] Task 4.1: Multimodal Forensic Flows** (Gemini 2.5 Flash Lite receipt checks).
*   **[x] Task 4.2: NLP Dispute Mediator** (Unbiased legal arbitration flow).
*   **[x] Task 4.3: Zero-Trust Guardrails** (Double-condition payout: AI Verified + Delivered).
*   **[x] Task 4.4: Prompt Injection Lockdown** (Hardened system mandates).
*   **[x] Task 4.5: Reasoning & Audit Logs** (AI now outputs step-by-step thinking).
*   **[x] Task 4.6: Autonomous Proof Run** (Captured logs of the agent acting alone).
*   **[x] Task 4.7: Intelligent Thresholds**
    *   **Action:** Final logic update to auto-dispute transactions where AI confidence is `< 85%`.

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

**Verification:** All AI-generated code and logic have been rigorously audited for security and Zero-Trust compliance by the human team leads.

# Amanah-Bot: Agentic AI Escrow-as-a-Service (EaaS)

**Amanah-Bot** is a Plug-and-Play, Agentic AI Escrow infrastructure designed to eliminate non-delivery and fake payment scams in peer-to-peer (P2P) marketplaces. Built for the **Project 2030 MyAI Future Hackathon (Track 5: FinTech & Security)**.

---

## 📌 Project Overview
Amanah-Bot elevates escrow from a standalone app to a scalable **B2B2C infrastructure**. It acts as a decentralized API and web-widget that individual sellers or platforms (like Mudah.my) can generate as a simple "Secure Checkout Link." It holds funds securely and uses AI agents to autonomously track courier statuses, verify payment receipts, and resolve disputes without human moderation.

### 🇲🇾 Problem Statement (Malaysia Context)
*   **Leading Category of Cybercrime:** E-commerce fraud is concentrated on platforms lacking native checkout security (Facebook Marketplace, Telegram, Instagram).
*   **Non-Delivery Scams:** Buyers send money and are immediately blocked by unverified sellers.
*   **Fake Payment Scams:** Sellers are defrauded by digitally manipulated DuitNow or bank transfer receipts.
*   **Friction:** Traditional escrow is slow and expensive for RM50–RM200 micro-transactions.

---

## ⚙️ How It Works (The Agentic Workflow)
1.  **The Plug-and-Play Link:** Seller generates a link and sends it to the buyer via WhatsApp.
2.  **Multimodal Receipt Verification (Agent 1):** Gemini 1.5 Pro analyzes the buyer's receipt for pixel manipulation and font inconsistencies.
3.  **Autonomous Tracking (Agent 2):** Firebase Genkit triggers a loop polling a simulated courier API (PosLaju/J&T) based on the tracking number.
4.  **Autonomous Execution:** The millisecond the courier returns "Delivered," Genkit unlocks the vault and routes funds to the seller.
5.  **AI Mediator (Agent 3):** If "Dispute" is clicked, Gemini analyzes chat logs and photo evidence to make an unbiased refund decision based on consumer protection laws.

---

## 🛠 Tech Stack
*   **Frontend:** **Flutter Web** (UI/UX excellence and web accessibility).
*   **Orchestration:** **Firebase Genkit** (The brain managing state transitions).
*   **Intelligence:** **Gemini 1.5 Pro API** (Multimodal forensics & NLP arbitration).
*   **Backend:** **FastAPI (Python)** (Mock Bank and Courier APIs).
*   **Deployment:** **Google Cloud Run** (Mandatory hackathon requirement).

---

## 📋 Role-Based Master Checklist (Exhaustive)

### **Role 1: Frontend Architect (Flutter Web)**
*   **[ ] Phase 1: Responsive Core (H1-4):**
    *   Initialize Flutter Web project with a clean, modern aesthetic.
    *   Implement a responsive layout that works on mobile (WhatsApp/Instagram browsers).
*   **[ ] Phase 2: Checkout Link Portal (H4-10):**
    *   Build the `amanah.bot/pay/{id}` landing page.
    *   Add a File Picker for receipt uploads (Images/PDFs).
    *   Implement real-time status UI (Pending → Verifying → Funded → Shipped).
*   **[ ] Phase 3: Seller Dashboard (H10-16):**
    *   Create a "Link Generator" form (Item Name, Price, Seller Wallet).
    *   Build an "Escrow Monitor" to view all active transaction statuses.
*   **[ ] Phase 4: Dispute & Arbitration UI (H16-20):**
    *   Build the "Dispute Raised" screen with photo evidence upload.
    *   Implement the "AI Mediator Chat" interface for automated resolution.
*   **[ ] Phase 5: Production Polish (H20-24):**
    *   Connect all UI components to live Cloud Run Backend URLs.
    *   Fix any CORS or cross-origin issues with the backend.

### **Role 2: Agentic Workflow & Security Lead (Genkit + Gemini)**
*   **[ ] Phase 1: Receipt Forensic Agent (H1-6):**
    *   Engineer a Multimodal Gemini 1.5 Pro prompt to detect font/pixel forgery in DuitNow receipts.
    *   Implement logic to cross-reference extracted receipt data with the Mock Bank API.
*   **[ ] Phase 2: State Machine Orchestration (H6-12):**
    *   Configure Firebase Genkit to manage the state flow: `Payment_Pending` → `Funded` → `In_Transit` → `Delivered`.
    *   Implement the autonomous polling loop for the Courier API.
*   **[ ] Phase 3: AI Arbitration Agent (H12-18):**
    *   Engineer the "AI Judge" prompt using consumer protection law context.
    *   Enable the agent to process multi-format evidence (Photos + Chat Logs).
*   **[ ] Phase 4: Zero-Trust Validation (H18-24):**
    *   Verify that the vault *only* releases funds upon automated courier delivery webhooks.
    *   Audit all prompts for "Prompt Injection" safety.

### **Role 3: Backend & Cloud Engineer (FastAPI + Cloud Run)**
*   **[x] Phase 1: Security & Repo Setup (H1-2):**
    *   Initialize GitHub Repo and set up exhaustive `.gitignore`.
*   **[x] Phase 2: Mock API Development (H2-6):**
    *   `GET /health`: Basic health check for Cloud Run monitoring.
    *   `POST /api/bank/verify`: Hardcoded payment confirmation endpoint.
    *   `GET /api/courier/track/{id}`: Dynamic status logic (1=Pending, 2=Transit, 3=Delivered).
*   **[ ] Phase 3: Containerization (H6-8):**
    *   Create a production-ready `Dockerfile` (Slim Python image).
    *   Bind `uvicorn` to the environment `$PORT` (default 8080).
*   **[ ] Phase 4: Cloud Run Deployment (H8-12):**
    *   Redeem Hackathon Credits and enable Cloud Run/Artifact Registry APIs.
    *   Deploy with "Allow Unauthenticated Invocations" for public access.
    *   Securely inject Gemini/Firebase keys into Cloud Run "Variables & Secrets."
*   **[ ] Phase 5: Documentation & Repo Audit (H12-24):**
    *   Finalize the **Mandatory AI Declaration** in README.
    *   Ensure NO hardcoded credentials exist in any committed file.

### **Role 4: Product Manager & Pitch Strategist**
*   **[ ] Phase 1: Registration (CRITICAL):**
    *   Complete Team Registration via Google Form by **TONIGHT 11:59 PM**.
*   **[ ] Phase 2: Pitch Deck (15 Slides):**
    *   Focus on Business Model (1.5% micro-fee), Scalability (EaaS), and National Impact.
*   **[ ] Phase 3: Video Demo Production:**
    *   Record a 3-minute "Flawless Flow" screen recording (No manual clicks, all AI-driven).
    *   Upload to YouTube (Unlisted) or Public Google Drive.
*   **[ ] Phase 4: Submission Logic:**
    *   Double-check GitHub Public URL, Cloud Run URL, and Deck PDF.
    *   Submit the final portal by **April 21, 11:59 PM**.

---

## ✅ Mandatory Submission Checklist
- [ ] **Cloud Run URL:** Live and publicly accessible.
- [ ] **GitHub Repo:** Public, clean code, and exhaustive README.
- [ ] **AI Declaration:** Explicitly included (See below).
- [ ] **Video Demo:** Max 3 minutes.
- [ ] **Pitch Deck:** Max 15 slides (PDF).

---

## 📝 AI Declaration & Compliance
This project utilizes the **Google AI Ecosystem Stack** as its core intelligence engine.

*   **Intelligence:** **Gemini 2.5 Flash Lite** was used for high-speed multimodal receipt forensics and legal-context arbitration.
*   **Orchestration:** **Firebase Genkit V1** was used to design agentic workflows and automated state transitions.
*   **Development:** **Gemini CLI** and **GitHub Copilot** were employed for architectural planning, boilerplate generation, and rapid documentation.

**Verification:** All AI-generated code and logic have been rigorously audited for security, prompt injection vulnerabilities, and idiomatic correctness by the human team leads.

---

## 🛠 Setup
1. `git clone https://github.com/Nitezio/myai-hackathon-AmanahBot`
2. Backend: `pip install -r requirements.txt` -> `uvicorn main:app --port 8080`
3. Frontend: `flutter pub get` -> `flutter run -d chrome`

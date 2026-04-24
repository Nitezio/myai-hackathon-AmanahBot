# Amanah-Bot: Agentic AI Escrow-as-a-Service (EaaS)

**Amanah-Bot** is a Plug-and-Play, Agentic AI Escrow infrastructure designed to eliminate non-delivery and fake payment scams in social commerce. Built for the **Project 2030 MyAI Future Hackathon (Track 5: FinTech & Security)**.

---

## 📌 Project Overview
Amanah-Bot elevates escrow from a standalone app to a scalable **B2B2C infrastructure**. It provides a "Secure Checkout Link" that sellers can share via WhatsApp, Instagram, or Telegram. The system autonomously holds funds, detects forensic fraud in receipts using **Gemini 2.5 Flash Lite**, and releases payments based on real-time courier API confirmations.

### 🇲🇾 Malaysia Context & Problem
*   **Social Commerce Fraud:** Malaysians lost over **RM2.7 billion** to online scams in 2025. 56% of these occur on messaging apps.
*   **Fake DuitNow Receipts:** Scammers use pixel-perfect AI-generated screenshots to trick sellers into releasing items.
*   **The Trust Gap:** Micro-transactions (RM50-RM200) lack affordable, fast, and secure escrow solutions.

---

## 🛠 Hackathon Toolstack Compliance
As per the **Project 2030** mandates, this project utilize the full Google AI Ecosystem:

| Tool | Purpose in Project |
| :--- | :--- |
| **Google Antigravity** | Our **Agentic IDE** for multi-agent orchestration and reasoning visualization. |
| **Android Studio** | The primary environment for **Flutter Web** development and network debugging. |
| **Google Cloud Run** | Multi-container production hosting (FastAPI Gateway + Genkit AI Hub). |
| **Firebase Genkit** | The core orchestration layer for autonomous state machine and polling loops. |
| **Gemini 2.5 Flash Lite** | High-speed multimodal intelligence for forensics and arbitration. |

---

## ✨ Core Features (Verified)
1.  **Hybrid AI Hub:** A bridged dual-engine (FastAPI + Genkit V1) that isolates high-stakes reasoning.
2.  **Multimodal Forensics:** Deep visual analysis of receipt pixels and fonts using **Gemini 2.5 Flash Lite**.
3.  **Digital Fingerprinting:** Independent **SHA-256 hashing** of every uploaded receipt to prevent duplicate-submission fraud.
4.  **Autonomous Agentic Polling:** Non-blocking background loops that "stalk" courier APIs without human input.
5.  **Zero-Trust Vault:** Fund release triggered ONLY by delivery confirmation AND verified AI forensics.
6.  **AI Mediator:** Unbiased NLP arbitrator that resolves disputes in seconds using Malaysian consumer law context.
7.  **Agentic Console UI:** A state-managed Flutter dashboard that displays the AI's **Chain-of-Thought** reasoning live.

---

## 📐 Technical Architecture & Data Flow
*   **Gateway (Python/FastAPI):** Manages the primary escrow state machine and serves the API for the Frontend.
*   **AI Engine (Node.js/Genkit):** Executes complex multimodal reasoning and generates forensic verdicts.
*   **Data Bridge:** Binary image data is captured by the Gateway, converted to **Base64**, and handshaked with the AI Engine.
*   **Intelligent Fail-Safe:** Enforces an **85% confidence threshold**. If AI is uncertain, the vault is locked and moved to `AUTO_DISPUTED`.
*   **Demo Mode:** Tracking numbers ending in **`3`** trigger an autonomous fast-forward progression (3s steps) for high-reliability presentations.

---

## 📋 Official Master Team Checklist

### **1. Project Manager & Pitch Strategist**
*   **[ ] Task 1.1: Official Registration (CRITICAL)** (Submit Google Form by Tonight 11:59 PM).
*   **[ ] Task 1.2: 15-Slide Pitch Deck (PDF)** (Focus on EaaS model, 1.5% fee, and National Impact).
*   **[ ] Task 1.3: 3-Minute Video Demo** (Record flow: Link Gen $\rightarrow$ AI Check $\rightarrow$ Auto-Release).
*   **[ ] Task 1.4: Final Portal Submission** (Finalize all 4 Cloud/GitHub/Video/PDF links).

### **2. Frontend Architect (Flutter Web)**
*   **[x] Task 2.1: Flutter Web Initialization** (High-contrast mobile-optimized layout).
*   **[x] Task 2.2: Checkout Screen (`/pay/{id}`)** (Integrated FileUpload and **Live Reasoning Bar**).
*   **[x] Task 2.3: Seller Dashboard** (Fully functional escrow link generator with one-tap share).
*   **[x] Task 2.4: Agent Activity Console** (Scrolling terminal UI for background AI tasks).
*   **[x] Task 2.5: Backend Integration** (Connected to Python Gateway via `ApiService`).

### **3. Backend & Cloud Lead**
*   **[x] Task 3.1: Hybrid Engine Bridge** (Verified Python ↔ Node.js Base64 data handshake).
*   **[x] Task 3.2: Multi-Service Containerization** (Production Dockerfiles ready for GCP).
*   **[x] Task 3.3: Deployment Automation** (Created `deploy_to_gcp.sh` for Cloud Run).
*   **[x] Task 3.4: Code Polish & Type Safety** (Added Pydantic models, type hints, and docstrings).
*   **[x] Task 3.5: Independent SHA-256 Layer** (Hashing implemented at the Gateway level).

### **4. Agentic Workflow & Security Lead**
*   **[x] Task 4.1: Multimodal Forensic Flows** (Gemini 2.5 Flash Lite receipt checks).
*   **[x] Task 4.2: NLP Dispute Mediator** (Unbiased legal arbitration flow).
*   **[x] Task 4.3: Zero-Trust Guardrails** (Double-condition payout: AI Verified + Delivered).
*   **[x] Task 4.4: Prompt Injection Lockdown** (Hardened mandates against instruction overrides).
*   **[x] Task 4.5: Reasoning & Audit Logs** (AI now outputs step-by-step thinking to UI).
*   **[x] Task 4.6: Autonomous Proof Run** (Empirically verified end-to-end self-driving loop).
*   **[x] Task 4.7: Intelligent 85% Threshold** (Auto-dispute logic for low AI confidence).

---

## 🛠 Teammate Testing Guide
To test the "Winning Flow" on your local machine:

1.  **Terminal 1 (AI Engine):**
    ```bash
    cd myai-hackathon-AmanahBot
    npm install
    npx tsx src/index.ts  # Runs on Port 3400
    ```
2.  **Terminal 2 (Gateway):**
    ```bash
    cd myai-hackathon-AmanahBot
    python main.py  # Runs on Port 8080
    ```
3.  **Terminal 3 (UI):**
    ```bash
    cd myai-hackathon-AmanahBot/amanah_ui
    flutter run -d chrome --dart-define=API_URL=http://localhost:8080
    ```
4.  **Test Case:** Use tracking number **`JNT8883`** to see the system autonomously walk through all 5 steps in 15 seconds.

---

## 🚀 Future Roadmap: Scaling Beyond the Hackathon
1.  **Event-Driven Data:** Transition from in-memory `escrow_db` to **Firebase Firestore**.
2.  **End-to-End Encryption:** Use **Web Crypto API** in Flutter to sign receipts on-device.
3.  **Real-Time Sync:** Replace polling with **Firebase Cloud Messaging** for instant UI updates.
4.  **Infrastructure Scaling:** Deploy as a **Browser Extension** for Facebook Marketplace.

---

## 📝 AI Declaration & Compliance
Amanah-Bot is built from the ground up using the **Google AI Ecosystem Stack**. This project transitions from simple "Chat" models to complex **Agentic AI** capable of autonomous real-world action.

*   **Intelligence:** **Gemini 2.5 Flash Lite** (High-speed multimodal Vision & NLP).
*   **Orchestration:** **Firebase Genkit V1** (Complex state transitions and tool-calling).
*   **Development:** **Gemini CLI** and **GitHub Copilot** (Architecture & Hardening).

**Verification:** 100% of AI-generated logic has been audited for security and Zero-Trust compliance by the human team leads.

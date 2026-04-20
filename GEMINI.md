# Amanah-Bot: Escrow-as-a-Service (EaaS)

## Project Overview
**Amanah-Bot** is a Plug-and-Play, Agentic AI Escrow infrastructure designed for the Malaysian P2P e-commerce market. It addresses the high rate of e-commerce fraud (non-delivery and fake payment scams) by acting as a decentralized API and web-widget. It holds funds securely and uses AI agents to autonomously track courier statuses, verify payment receipts, and resolve disputes without human moderation.

- **Hackathon:** Project 2030 MyAI Future Hackathon (Track 5: FinTech & Security).
- **Core Value Prop:** "Zero-Trust" commerce for micro-transactions (RM50–RM200) via automated, machine-speed escrow release and AI-driven arbitration.

## Technical Architecture
- **Frontend/Widget:** Flutter Web (Responsive UI for buyers/sellers).
- **Orchestration (The Brain):** Firebase Genkit (State machine for escrow flow).
- **Intelligence:** Gemini 1.5 Pro API (Multimodal receipt forensics & NLP dispute resolution).
- **Backend Simulators:** FastAPI (Python) or Node.js (Mock APIs for PosLaju/J&T and Banking).
- **Deployment:** Google Cloud Run (Containerized backend and frontend).

## Hierarchical Project Structure & RBAC
Adhering to the established organizational mandate, this project operates under a three-tier hierarchical oversight:

1.  **Project Manager (Team Leader):** Oversees strategic alignment, pitch deck development, and final submission logic.
2.  **DevSecOps Architect:** Manages infrastructure, Google Cloud Run deployment, Dockerization, and CI/CD pipelines.
3.  **Security & Integration Auditor:** Performs rigorous code reviews, ensures no hardcoded secrets exist, and validates the "AI Declaration" compliance.

## Building and Running
*Note: These commands are inferred from the planned tech stack and will be updated as the codebase grows.*

### Backend (FastAPI)
- **Setup:** `pip install -r requirements.txt`
- **Run:** `uvicorn main:app --host 0.0.0.0 --port 8080`
- **Mock APIs:** Access Swagger docs at `/docs`.

### Frontend (Flutter Web)
- **Setup:** `flutter pub get`
- **Run:** `flutter run -d chrome`
- **Build:** `flutter build web`

### Deployment
- **Docker:** `docker build -t amanah-backend .`
- **Cloud Run:** `gcloud builds submit --tag gcr.io/[PROJECT_ID]/amanah-backend`

## Development Conventions
- **Security First:** NEVER commit `.env` files or API keys. Use GCP Secret Manager or environment variables in Cloud Run.
- **Agentic Workflow:** AI should take autonomous actions (polling APIs, releasing funds), not just providing conversational feedback.
- **AI Disclosure:** All source code must explicitly declare the use of AI tools (Copilot/Gemini) in the README.
- **Code Quality:** Modular, commented code is required to secure the 15-mark evaluation criteria.

## Project Progress Log

### [2026-04-20] - Project Initialization
- **Status:** Initialized GitHub Repository (`myai-hackathon-AmanahBot`).
- **Done:**
    - Defined project architecture and tech stack.
    - Assigned roles and execution phases.
    - Created foundational documentation and instructional context (GEMINI.md).
- **Next Steps:**
    - Initialize FastAPI backend and create Mock APIs (Bank/Courier).
    - Configure `.gitignore` and security baseline.
    - Set up Firebase Genkit orchestration.

---
*This file serves as the foundational instructional context for Gemini CLI. All future interactions must respect the constraints and architectural decisions outlined here.*

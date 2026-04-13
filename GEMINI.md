# 🛠 Project Context: CAMI

> **Status:** Exploration / MVP
> **Primary AI:** Gemini 3 Pro (Cloud) / Qwen3-Coder (Local Discovery)
> **Last Sync:** 2026-03-21

---

## 🎯 Current Mission

- **Objective:** Establish core architecture, document decisions, and prepare the project foundation.
- **Current Sprint:** Document conventions, finalize toolchain setup, and complete environment configuration tasks.

---

## 🏗 Technical Manifesto (The Stack)

- **Backend:** Ruby on Rails 8.0 (Monolith), PostgreSQL, Solid Queue (Background Jobs)
- **Frontend:** Inertia.js, React 19+, TypeScript, Tailwind CSS, Flowbite, Vite
- **DevOps:** Render, Docker (web & worker), Ngrok (Development)
- **Quality:** RSpec (Backend), Vitest (Frontend), RuboCop (Ruby Linting), ESLint (JS Linting)
- **Tooling:** Thor (CLI Tasks), VCR/Faraday (HTTP/Testing), Rswag (API Docs)

---

## 🤖 Rules of Engagement

- **Discovery:** Full permission to `ls`, `cat`, `grep`, and `find`. Use local MCP/Ollama for discovery to minimize token cost.
- **Project Management:** Prefer Linear for all project management tasks and issue tracking.
- **Agentic Scripts:** Locate all agnostic agentic scripts in `.agents/shared/bin` and Gemini-specific scripts in `.agents/gemini/bin`.
- **Validation:** Use `.agents/shared/bin/validate` to run the full suite (RSpec, RuboCop, ESLint, Vitest) concurrently.

---

## 📋 Progress Tracker

- [x] Phase 1: Infrastructure & Boilerplate
- [ ] Phase 2: Core Logic / API
- [ ] Phase 3: Frontend Integration
- [ ] Phase 4: CI/CD & Deployment

---

## 🧠 Shared Memory (Hand-off Log)

_This section is the relay between Gemini (Home) and Claude (Work)._

### Context Summary for Next Session

- Just established the project-specific `GEMINI.md` and documented core
  architectural decisions (Inertia.js, Solid Queue, Vite).
- Addressed Copilot PR feedback for PR #264 in the
  `refactor/docs-and-base-setup` branch.
- Consolidated Swagger definitions and refactored request specs into a single
  `events_spec.rb` to eliminate duplicate POST operations and OAS syntax errors.
- Fixed OpenAPI 3.0 syntax errors related to sibling keywords on `$ref` and
  redundant top-level keys in example payloads.
- Updated `.replit` to Ruby 3.4.4 and restored `packageManager: "yarn@4.9.1"` in
  `package.json`.
- Uncommented Knapsack Pro matrix configurations in
  `.github/workflows/full-stack.yml` and defined a default `RUN_MODE`.
- Verified changes with `rspec` and `rswag:specs:swaggerize` (all green) and
  ensured clean `rubocop` status.
- Next steps: Review the updated PR on GitHub and wait for final approval/merge.

---

## 🛠 MCP Tooling Reference

- **DB:** `postgresql-mcp` (Local introspection enabled)
- **Shell:** `google-cloud-sdk` (GCP CLI context enabled)

---

## 🚀 Session Startup Routine (Automated)

The session startup interview and "Inference-First" protocol are now managed globally by the **Ralph extension startup hook**.

- **Behavior:** The agent will automatically attempt to infer your goals and stack focus from your initial prompt.
- **Manual Control:** If inference is insufficient, an interview will be presented with a **"Skip entire interview"** option.
- **Global Config:** To modify this behavior across all projects, edit the hook at `~/.gemini/extensions/ralph/hooks/session-start.sh`.

Update the Shared Memory section below at the end of your session to ensure smooth context hand-off.

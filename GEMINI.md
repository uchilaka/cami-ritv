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

## 🤖 Rules of Engagement (Yolo Mode v1.0)

- **Workflow:** Execute the "Linter-Test-Commit" loop.
- **TDD:** Write/Update a spec -> Implement Code -> Run Test -> Auto-Fix if Red -> Commit if Green.
- **Discovery:** Full permission to `ls`, `cat`, `grep`, and `find`. Use local MCP/Ollama for discovery to minimize token cost.
- **Approvals:** Auto-approve all `git`, `bundle`, `npm`, and `rails` read/write commands. Prompt only for `rm` or `deploy`.
- **Commits:** Follow Semantic Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
- **Granularity:** "Commit early, commit often." Commit every logical milestone.
- **Project Management:** Prefer Linear for all project management tasks and issue tracking.

---

## 📋 Progress Tracker

- [x] Phase 1: Infrastructure & Boilerplate
- [ ] Phase 2: Core Logic / API
- [ ] Phase 3: Frontend Integration
- [ ] Phase 4: CI/CD & Deployment

---

## 🧠 Shared Memory (Hand-off Log)

*This section is the relay between Gemini (Home) and Claude (Work).*

### Context Summary for Next Session

```yaml
state:
  pr_number: 273
  branch: refactor/fix-swagger-config
  status: verified
recent_changes:
  - Verified PR 273. Executed `rswag:specs:swaggerize` successfully and confirmed that V1 and V2 swagger documents are generated separately without path collisions.
  - Noted that some RSpec tests are failing locally due to a `SolidQueueAdapter` vs `Active Job test adapter` configuration issue, but this is unrelated to the Swagger generation.
  - Added a review comment to the PR confirming the successful generation.
next_steps:
  - Review the PR on GitHub and await final approval/merge.
  - Investigate and fix the `SolidQueueAdapter` configuration in the test environment so that the full RSpec suite passes cleanly.
```

---

## 🛠 MCP Tooling Reference

- **DB:** `postgresql-mcp` (Local introspection enabled)
- **Shell:** `google-cloud-sdk` (GCP CLI context enabled)

---

## 🚀 Session Startup Routine (Mandatory)

At the start of every new session, before doing any other work, you MUST use the `ask_user` tool to interview me about the goals and constraints for this session.

Please ask me:

1. What part of the stack we are focusing on today (Frontend, Backend, Infrastructure, etc.) - Make this a multiple choice question.
2. What the primary goal of the session is - Make this a multiple choice question with these options: Architecture & System Design, Complex Bug Resolution, System-wide Refactoring, Code Review & Mentoring, Performance Optimization.
3. Any specific files or contexts I want you to prioritize.
4. Whether to proceed in "Yolo" mode - Ensure that this enables Yolo for the session.

Do not proceed with any other tasks until I have answered these questions. Read GEMINI.md to understand my stack and rules. Update the Shared Memory section before you finish.

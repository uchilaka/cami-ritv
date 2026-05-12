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
  status: homelab_architecture_defined
  plan_path: ~/project-plans/cami-ritv/HOMELAB_MIGRATION.md
recent_changes:
  - Finalized 'Homelab Migration Plan' (Tailscale + Traefik Hub/Spoke).
  - Configured Bouncer (DO) wildcard routing for *.lab.larcity.tech and *.beta.larcity.tech.
  - Implemented Spoke architecture for local nodes (NAS/Mac Mini) using port 9090.
  - Documented Real-World WordPress example for NAS routing.
  - Updated global GEMINI.md to prioritize project plans in '~/project-plans/'.
next_steps:
  - Phase 4: Establish Tailscale Mesh across all 3 nodes (Droplet, NAS, Mac Mini).
  - Phase 5: Deploy Spoke Traefiks on NAS and Mac Mini (Port 9090).
  - Phase 6: Deploy Hub Traefik on Bouncer Droplet.
  - Review and merge Draft PR #265.
```

---

## 🛠 MCP Tooling Reference

- **DB:** `postgresql-mcp` (Local introspection enabled)
- **Shell:** `google-cloud-sdk` (GCP CLI context enabled)

---

## 🚀 Session Startup Routine (Mandatory)

At the start of every new session, before doing any other work, you MUST use the `ask_user` tool to interview me about the goals and constraints for this session.

**Step 1: Inference & Topline Skip**
- Attempt to infer the answers to the questions below from my initial prompt.
- If you can confidently infer all answers, skip the interview and summarize your assumptions.
- Otherwise, present the interview but include a **topline option to "Skip entire interview"**.

**Step 2: The Interview**
If an interview is necessary, ask:

1. What part of the stack we are focusing on today? (e.g., Frontend, Backend, Infrastructure, etc.) - Multiple choice.
2. What is the primary goal of the session? (Options: Architecture & System Design, Complex Bug Resolution, System-wide Refactoring, Code Review & Mentoring, Performance Optimization).
3. Any specific files or contexts I want you to prioritize?

**Rules for the Interview:**
- **No individual "Skip" options:** Do not add "Skip" or "None" to individual questions.
- **Unanswered = Skipped:** If I leave a question unanswered, treat it as skipped and proceed with sensible defaults.
- **Stop for Clarification:** If my goals are fundamentally ambiguous or I provide conflicting instructions, stop and ask for clarification.
- **Auto-Approval Tip:** If you are being asked for confirmation too often, you can toggle auto-approval directly:
  - **Gemini CLI:** Press `Ctrl+Y` to toggle YOLO mode (or `Shift+Tab` to cycle modes).
  - **Claude Code:** Press `Shift+Tab` to select "Auto" mode (or start with `claude --enable-auto-mode`).

Do not proceed with any other tasks until I have answered these questions or the interview is skipped. Read GEMINI.md to understand my stack and rules. Update the Shared Memory section before you finish.

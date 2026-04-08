# CAMI: AI Assistant & CoPilot Configuration

Quick reference for using GitHub Copilot, Windsurf, and custom agents with the CAMI project.

## 📋 Quick Links

- **Custom Agent**: CAMI Architect agent definition → [`.github/agents/cami-architect.agent.md`](../../.github/agents/cami-architect.agent.md)
- **Validation Log**: Assessment of CoPilot compliance → [`docs/copilot/VALIDATION_LOG.md`](./VALIDATION_LOG.md)
- **Architectural Decisions**: Project decisions → [`docs/decisions/`](../decisions/)
- **AI Strategy ADR**: Decision record for this setup → [`docs/decisions/006-implement-ai-copilot-custom-agent-and-instructions.md`](../decisions/006-implement-ai-copilot-custom-agent-and-instructions.md)
- **Windsurf Rules**: Development guidelines → [`.windsurf/rules/`](../../.windsurf/rules/)
- **Contributing**: Semantic commits & guidelines → [`docs/CONTRIBUTING.md`](../CONTRIBUTING.md)

## 🤖 Using the CAMI Architect Agent

The `CAMI Architect` custom agent is optimized for this project and automatically activates when working on:
- Rails backend features (`app/**/*.rb`, `lib/**/*.rb`)
- React components (`app/frontend/**/*.{ts,tsx}`)
- Architecture or documentation (`docs/**/*.md`)

### Recommended Prompts

**For business logic:**
```
@CAMI-Architect Create an Interactor for [feature name]
```

**For UI components:**
```
@CAMI-Architect Implement a React component for [feature] using InertiaJS
```

**For architecture decisions:**
```
@CAMI-Architect Write an ADR for [architectural decision]
```

**For testing:**
```
@CAMI-Architect Write RSpec request tests for [endpoint/feature]
```

## 🏗️ Project Architecture At a Glance

| Layer | Tech | Key Files |
|-------|------|-----------|
| **Frontend** | React + InertiaJS + Vite | `app/frontend/` |
| **Backend** | Rails 3.4 + Interactor | `app/controllers/`, `app/services/` |
| **Styling** | TailwindCSS + Flowbite | `tailwind.config.js` |
| **Testing** | RSpec + RSWag | `spec/` |
| **CLI** | Thor | `lib/commands/` |
| **HTTP** | Faraday | `lib/lar_city/http_client.rb` |

## ⚙️ Key Patterns (From Windsurf Rules)

1. **Service Objects**: Use Interactor gem for business logic (ADR-003)
2. **Testing**: RSpec for request/unit tests, RSWag for API specs (ADR-005)
3. **Fixtures**: Fabricator over FactoryBot
4. **HTTP**: Faraday client with VCR stubbing (ADR-001, ADR-004)
5. **UI**: ERB + Stimulus/Turbo preferred; React+InertiaJS when needed
6. **Config**: YAML over other formats
7. **Icons**: Flowbite icons only
8. **Decisions**: ADR format in `docs/decisions/`

## 📝 When to Create an ADR

The agent will suggest ADRs when:
- Making a significant architectural choice
- Establishing a new pattern or standard
- Choosing between multiple technical approaches
- Documenting a decision that affects multiple team members

**Format**: `docs/decisions/###-short-title.md` (see [`documentation-standards.md`](../documentation-standards.md))

## 🔍 GitHub Copilot vs. Windsurf

- **Windsurf Rules** (`.windsurf/rules/`): Quick suggestions for patterns, automatically triggered
- **CAMI Architect Agent** (`.github/agents/cami-architect.agent.md`): In-depth assistance for complex tasks
- **Copilot Instructions**: Coming soon (recommended future implementation - see [`VALIDATION_LOG.md`](./VALIDATION_LOG.md))

## ✅ Compliance Checklist

Before opening a PR:

- [ ] New business logic encapsulated in Interactor or service object
- [ ] Tests written in RSpec with appropriate fixtures (Fabricator)
- [ ] API endpoints documented with RSWag request specs
- [ ] HTTP integrations use `LarCity::HttpClient` (Faraday)
- [ ] Architectural decisions documented as ADRs
- [ ] Commit messages follow semantic convention
- [ ] UI follows ERB + Stimulus/Turbo or React + InertiaJS pattern
- [ ] Styling uses TailwindCSS + Flowbite only
- [ ] Documentation updated in README or `docs/`

## 🔗 Related Documentation

- [`CONTRIBUTING.md`](../CONTRIBUTING.md) — Semantic commits
- [`DEVELOPMENT.md`](../DEVELOPMENT.md) — Local setup
- [`documentation-standards.md`](../documentation-standards.md) — ADR format
- [`MODELING.md`](../MODELING.md) — Data modeling guide
- [`INERTIAJS.md`](../INERTIAJS.md) — InertiaJS integration guide

---

**Last Updated**: March 23, 2026  
**Created by**: CAMI Project Validation  
**Status**: ✅ Recommended for team review

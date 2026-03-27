# 006. Implement AI/CoPilot Custom Agent & Instructions for Codebase Guidance

## Status
Accepted

## Context
The CAMI project has strong documentation standards (ADRs in `docs/decisions/`), established Windsurf rules (`.windsurf/rules/`), and clear architectural patterns (Interactor, RSpec, Faraday, etc.). However, GitHub Copilot, Windsurf, and other AI assistants lack explicit project context beyond the source code itself. This leads to:

1. **Inconsistent guidance**: AI tools suggest patterns not aligned with project standards (e.g., FactoryBot instead of Fabricator, Webmock instead of VCR)
2. **Missed opportunities**: AI assistants don't know about ADR-001 through ADR-005, project conventions, or Windsurf rules
3. **Incomplete PRs**: New features may lack ADRs, RSWag tests, or Interactor encapsulation because guidance isn't explicit
4. **Team onboarding friction**: New developers can't easily offload architecture questions to AI

## Decision
Implement comprehensive AI/CoPilot customization for the CAMI project:

1. **Create custom agent** - Define a specialized "CAMI Architect" agent
   - Location: `.github/agents/cami-architect.agent.md`
   - Targets: Rails backend, React components, architecture docs
   - Persona: Expert in project patterns, standards, and dependencies
   - Restrictions: Avoid recommending non-preferred tools/patterns
   - Triggers: Automatically for relevant file types

2. **Document AI compliance** - Create structured validation and tracking
   - `docs/copilot/VALIDATION_LOG.md` - Assessment of consistency with project standards
   - `docs/copilot/SETUP.md` - Developer guide for using AI tools effectively
   - ADR-006 (this document) - Decision to formalize AI collaboration

3. **Create implementation plan** (recommended future work)
   - `.instructions.md` - Formal copilot-instructions.md with detailed project context
   - Enhance `.windsurf/rules/` with YAML frontmatter specificity
   - Update README.md "Future work" section to reflect AI setup completion

## Consequences

### Positive
- **Consistency**: AI-assisted development follows project patterns automatically
- **Quality**: New code includes tests, ADRs, and service encapsulation by default
- **Onboarding**: New developers get immediate feedback aligned with team standards
- **Documentation**: AI encourages thorough ADR documentation for decisions
- **Flexibility**: Can be extended with additional agents for specializations (e.g., API design)
- **Maintainability**: Centralized source of truth for "how we do things here"

### Negative
- **Maintenance burden**: Requires periodic updates as standards evolve
- **Adoption**: Team must trust and actively use AI guidance (requires culture shift)
- **False confidence**: AI might miss context; humans still responsible for final review

### Risks
- **Tool lock-in**: If we over-customize for GitHub Copilot, we limit other AI tools
- **Staleness**: Agent definitions must be updated when architecture changes
- **Over-specification**: Too many constraints could inhibit creative problem-solving

## Implementation Notes

### Version 1 (Completed - March 23, 2026)
- ✅ `.github/agents/cami-architect.agent.md` created with full architecture context
- ✅ `docs/copilot/VALIDATION_LOG.md` created with compliance findings
- ✅ `docs/copilot/SETUP.md` created as developer guide
- ✅ This decision documented as ADR-006
- ✅ Files organized under `.copilot/` and `docs/copilot/` directories

### Version 2 (Recommended Future Work)
- ⏳ Create `.copilot/instructions.md` for GitHub Copilot Chat compatibility
- ⏳ Create additional specialized agents in `.github/agents/` (e.g., Testing, API Design)
- ⏳ Enhance `.windsurf/rules/` with `applyTo` patterns and documentation URLs
- ⏳ Update README.md "Future work" section to reference `.copilot/agents/`
- ⏳ Create additional specialized agents (e.g., Testing, API Design)

### Team Actions
1. Review `.agent.md` and validate it matches your working agreements
2. Read `docs/COPILOT_SETUP.md` and share with team
3. Try the agent with recommended prompts from the setup guide
4. Provide feedback for Version 2 enhancements

## Related ADRs & Documents
- **ADR-001**: Use Faraday for HTTP (referenced in agent)
- **ADR-002**: Use named parameters (referenced in patterns)
- **ADR-003**: Use Thor for tasks (referenced in patterns)
- **ADR-004**: Prefer VCR + Faraday stubbing (referenced in patterns)
- **ADR-005**: Prefer RSWag for request specs (referenced in patterns)
- **docs/documentation-standards.md**: ADR format template
- **docs/copilot/VALIDATION_LOG.md**: Compliance assessment
- **docs/copilot/SETUP.md**: Developer guide
- **.github/agents/cami-architect.agent.md**: Custom CAMI Architect agent
- **.windsurf/rules/**: Existing architectural guidelines

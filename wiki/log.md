# CAMI Wiki — log

**Append-only.** Newest entries at the bottom. Never edit or reorder an existing
entry; if something recorded here turns out to be wrong, append a correction that
references it.

Every ingest, every query filed back as a page, and every lint run gets an entry.
This is the wiki's audit trail: it answers "when did we learn this, and from
what?" — which `index.md` deliberately does not.

Entry format:

```markdown
## YYYY-MM-DD — <ingest|query|lint|schema> — <short title>

- **Source:** what was read (repo ref, PR, ticket, file, or external source id)
- **Commit:** sha the source was read at
- **Pages touched:** [[slug]] (created|updated), [[slug]] (updated)
- **Notes:** contradictions found, questions raised, anything a reader should know
```

---

## 2026-09-20 — schema — wiki scaffolded

- **Source:** [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- **Commit:** `1fdf4ad1` (1300 commits on `spike/llm-wiki`, branched from `origin/main`)
- **Pages touched:** none — scaffold only
- **Notes:** Established `CLAUDE.md` (schema), `index.md` (catalog), this log,
  flat `pages/`, `sources/manifest.md`, and the `/wiki-ingest`, `/wiki-query`,
  `/wiki-lint` skills under `.claude/skills/`. Corpus is the CAMI codebase and
  `docs/`. Key adaptation of the pattern for a code corpus: pages cite
  `path:line` plus a `verified_at` commit rather than copying source text, so
  staleness is mechanically checkable at `HEAD`. No sources ingested yet.

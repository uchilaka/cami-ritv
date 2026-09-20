# CAMI Wiki — schema and operating rules

This directory is an **LLM-maintained wiki** over the CAMI codebase, following the
pattern in [Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

Knowledge is **compiled once and kept current**, not re-derived on every question.
When you learn something about this codebase worth keeping, it belongs here as a
page — not in a chat reply that evaporates.

> **This file is the schema.** It governs how pages are shaped, linked and
> maintained. Read it before writing to `wiki/`. If a rule here conflicts with
> what you were about to do, the rule wins — or change the rule deliberately and
> record that in `log.md`.

## The three layers

| Layer | Where | Mutability |
|---|---|---|
| **Raw sources** | the repository itself, at a given commit | immutable (git history) |
| **The wiki** | `wiki/pages/` | LLM-maintained, always current |
| **The schema** | this file | changed deliberately, by humans |

The adaptation that matters for a *code* corpus: our sources are already
versioned, so a page never copies them. It **cites** them — `path:line` plus the
commit it was verified against. That makes staleness and contradiction
**mechanically checkable** rather than a matter of opinion, which is what gives
`/wiki-lint` something real to do.

## Layout

```
wiki/
  CLAUDE.md          this file — the schema
  index.md           catalog of every page, one line each (the map)
  log.md             append-only record of ingests, queries, maintenance
  pages/             the wiki proper — FLAT, kebab-case slugs
  sources/
    manifest.md      what has been ingested, at which commit
    external/        non-repo sources (ticket exports, articles, transcripts)
  templates/
    page.md          copy this to start a page
    source.md        copy this to record an external source
```

`pages/` is **flat on purpose.** Categories live in `index.md`, not in directory
paths, so recategorising a page never breaks a `[[link]]`. Slugs are therefore
globally unique and must read as nouns: `job-queue`, `omniauth-flow`,
`credentials-resolution`.

## Page contract

Every page in `pages/` opens with this frontmatter:

```yaml
---
title: Human readable title
slug: kebab-case-slug        # must equal the filename without .md
kind: concept | entity | decision | runbook | question
status: current | stale | contested
updated: YYYY-MM-DD
verified_at: <commit sha>    # the commit whose code this page was checked against
cites:                       # repo paths this page makes claims about
  - app/models/invoice.rb
  - config/initializers/omniauth.rb
---
```

Then the body, in this order:

1. **One-paragraph answer.** What a reader needs if they read nothing else.
2. **Detail** — the mechanism, with `path:line` references.
3. **Related** — `[[slug]]` links, each with a few words on *why* it's related.
4. **Open questions** — bullets. Empty is fine; absent is not.

### Conventions

- **Link liberally.** `[[slug]]` to a page that doesn't exist yet is not an
  error — it's a claim that the page *should* exist, and `/wiki-lint` reports it
  as a wanted page. This is how the wiki tells you what to write next.
- **Cite, never paste.** Quote at most a few lines of code. The repo is the
  source of truth; a page that duplicates it will rot.
- **Flag contradictions in place**, where a reader will hit them:

  ```markdown
  > ⚠️ **Contradiction:** `docs/DATABASE.md` says connections pool at 5;
  > `config/database.yml:12` sets 25. Unresolved as of 2026-09-20.
  ```

  Never silently pick a winner. The flag is the value.
- **Prefer updating a page to adding one.** Ten sharp pages beat forty stubs.
- **Never edit `log.md` except by appending.**

## The three operations

| Operation | Skill | What it does |
|---|---|---|
| **Ingest** | `/wiki-ingest` | Read a source, update every page it touches, append to `log.md` |
| **Query** | `/wiki-query` | Answer from the wiki; file a durable answer back as a page |
| **Lint** | `/wiki-lint` | Find staleness, contradictions, orphans, missing links |

Ingest is **not** indexing. One source typically touches several pages — a PR
that changes auth updates `omniauth-flow`, `session-storage` and
`deployment-secrets`, and may create `csrf-handling`. If an ingest updated
exactly one page, it probably under-read the source.

## What belongs here — and what does not

**Does belong:** how a subsystem actually works; why a non-obvious decision was
made; the shape of a recurring bug; operational knowledge that lives only in
someone's head; contradictions between docs and code.

**Does not belong:**

- Anything the code states plainly and unambiguously — read the code.
- Anything `docs/` already covers well. The wiki **links to** `docs/`; it does
  not duplicate it. Where they disagree, that is a contradiction to flag.
- Secrets, credentials, `.env` contents, key material. Never. The wiki is
  committed to a shared repository.
- Transient state — a failing test you're mid-debug, a WIP branch.

## Staleness

A page is **stale** when any of:

- a path in `cites:` no longer exists at `HEAD`;
- a cited path has changed since `verified_at`;
- `verified_at` is more than ~200 commits behind `HEAD`.

`/wiki-lint` checks the first two mechanically. Stale is not wrong — it means
"unverified since". Mark `status: stale` rather than deleting; a stale page with
a marker is more useful than a gap.

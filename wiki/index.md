# CAMI Wiki — index

The map of this wiki. Every page in `pages/` gets exactly one line here, grouped
by theme. Categories live here rather than in directory paths so that
recategorising a page never breaks a `[[link]]`.

Maintained by `/wiki-ingest` and audited by `/wiki-lint`. See
[CLAUDE.md](./CLAUDE.md) for the page contract.

**Pages: 0.** Nothing ingested yet — run `/wiki-ingest` against a source to
start. Suggested first sources are listed in
[sources/manifest.md](./sources/manifest.md).

---

## Architecture

How the application is put together — request lifecycle, Inertia/React boundary,
background jobs, data access.

*(no pages yet)*

## Domain

The business objects and their rules — accounts, invoices, profiles, and the
invariants that hold between them.

*(no pages yet)*

## Configuration & secrets

How the app resolves configuration: `.env.<environment>`, git-crypt, Rails
encrypted credentials, and which wins when they disagree.

*(no pages yet)*

## Operations

Deploys, containers, environments, observability, the platform it runs on.

*(no pages yet)*

## Decisions

Why things are the way they are. Pages of `kind: decision` — a durable
counterpart to `docs/decisions/`, which this section should link to rather than
restate.

*(no pages yet)*

## Open questions

Questions raised by an ingest that nobody has answered yet. Pages of
`kind: question`. A question that gets answered becomes a `concept` page; the
question page is then replaced by a `[[link]]` to it.

*(no pages yet)*

---

## Wanted pages

`[[links]]` that point at pages which don't exist yet — the wiki's own backlog.
Populated by `/wiki-lint`; do not edit by hand.

*(none — no pages to link from yet)*

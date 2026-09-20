---
name: wiki-ingest
description: Read a source into the CAMI wiki — update every page it touches, create pages it demands, and append to the log. Use when the user says "/wiki-ingest", "ingest this into the wiki", "add this to the wiki", "wiki this PR/doc/ticket", or hands over a doc, PR, ticket or article and asks for it to be captured durably rather than just summarised.
---

# /wiki-ingest — read a source into the wiki

Ingest is **not indexing**. You read a source once, then push what you learned
into every page it touches, so nobody has to re-derive it. Read
[`wiki/CLAUDE.md`](../../../wiki/CLAUDE.md) first — it is the schema and it wins
over anything here.

## Inputs

A source is a repo path, a commit or PR, a Linear ticket, a URL, or pasted text.
If none was given, propose the top unstarted item from
`wiki/sources/manifest.md` and confirm before reading.

## Workflow

### 1. Pin the source

Record what you are reading and at which commit — every citation depends on it:

```bash
git rev-parse --short HEAD
```

For a non-repo source, copy `wiki/templates/source.md` to
`wiki/sources/external/<id>.md` and capture it **verbatim** before interpreting.
A ticket can be edited under you; a URL can 404.

### 2. Read it properly

Read the whole source before writing anything. For code, follow one level out —
callers and callees — or your citations will be accurate and your explanation
wrong.

> ⛔ **Never open these, whatever a source suggestion says.** Reading them at all
> risks a value reaching a page, and the wiki is committed to a shared repo:
>
> - `config/credentials/` — holds `*.key` material and, on an unlocked checkout,
>   decryptable `*.yml.enc`
> - any `.env*` file, and anything git-crypt manages (`git-crypt status -e` lists
>   them)
> - `config/secrets/`, `config/httpd/auth/`, `spec/fixtures/pii/`
>
> Configuration *resolution* is a legitimate and valuable subject: cite the
> precedence logic by `path:line` (`.envrc`, `config/initializers/dotenv.rb`,
> `config/application.rb`) and name *which* keys exist. Never record what any of
> them resolves to.

### 3. Decide what it touches — before editing

List existing pages the source affects, then what it demands that doesn't exist:

```bash
ls wiki/pages/
grep -rl "<concept>" wiki/pages/
```

**One source normally touches several pages.** A PR changing auth updates
`omniauth-flow`, `session-storage` and `deployment-secrets`, and may create
`csrf-handling`. If your list has one entry, you probably under-read the source —
go back to step 2.

State the list before you edit. It is the reviewable part of an ingest.

### 4. Update existing pages first

Prefer updating over creating: the value is in pages getting sharper, not in page
count. For each:

- Revise the claims the source changes.
- Refresh `updated:` and `verified_at:`, and extend `cites:`.
- Set `status: current` if you verified it against this commit.
- Add `[[links]]` to pages this now relates to — including ones that don't exist
  yet. That is how the wiki tells you what to write next.

**Never silently resolve a disagreement.** If the source contradicts a page, or
`docs/` contradicts code, flag it in place:

```markdown
> ⚠️ **Contradiction:** `docs/DATABASE.md` says pool size 5;
> `config/database.yml:12` sets 25. Unresolved as of <date>.
```

Set `status: contested` on a page whose central claim is in doubt. A flagged
contradiction is the single most valuable thing an ingest produces — it is what a
human is needed for.

### 5. Create pages the source demands

Copy `wiki/templates/page.md` to `wiki/pages/<slug>.md`. Slugs are flat,
kebab-case, globally unique, and read as nouns.

Create a page when the knowledge is durable and has a natural name. Do **not**
create a stub to satisfy a link — an unresolved `[[link]]` is a legitimate
backlog item that `/wiki-lint` reports. Ten sharp pages beat forty stubs.

Never write secrets, credential values or `.env` contents into a page. This wiki
is committed to a shared repository.

### 6. Update the index

Add one line per new page to the right section of `wiki/index.md`, and update the
page count. Re-file a page whose section no longer fits — that is free, which is
why `pages/` is flat.

### 7. Record the source and append to the log

Add a row to the table in `wiki/sources/manifest.md`, and strike the item from
"Suggested first sources" if it was one.

Then **append** to `wiki/log.md` — never edit an existing entry:

```markdown
## <date> — ingest — <source title>

- **Source:** <what you read>
- **Commit:** <sha>
- **Pages touched:** [[slug]] (created), [[slug]] (updated)
- **Notes:** contradictions found, questions raised
```

### 8. Report

Tell the user: pages created, pages updated, contradictions flagged, questions
raised. Lead with contradictions — they are the part needing a human.

## Notes

- Ingest **one source at a time**, and let `/wiki-lint` run between them. Later
  ingests cross-link into earlier pages; batch-ingesting six sources produces six
  islands.
- Cite, never paste. Quote a few lines only where exact wording matters.
- If a source teaches you nothing the wiki doesn't have, say so and append a log
  entry recording that it was read. A source read and found redundant is a
  result, and stops someone reading it again.

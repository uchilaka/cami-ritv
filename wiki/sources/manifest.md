# Ingested sources

What the wiki has read, and the commit it read it at. `/wiki-lint` reads the
**Commit** column and reports any row whose commit is far behind `HEAD`, as a
prompt to re-read that source.

It reports distance rather than deciding: the **Source** column is free text, not
a path, so a markdown manifest cannot diff per-source automatically. Page-level
staleness *is* mechanical — that comes from each page's `cites:` and
`verified_at`, which is why pages carry them.

For repository sources the content is *not* copied here — git already holds it
immutably. Only non-repo sources (ticket exports, articles, meeting notes) get a
file, under `external/`, recorded with `templates/source.md`.

| Date | Source | Kind | Commit | Pages touched |
|---|---|---|---|---|
| — | *nothing ingested yet* | — | — | — |

## Suggested first sources

Ordered by payoff — each is dense, load-bearing, and currently understood by
only a few people.

1. **`docs/CONFIG.md` + `.envrc` + `config/initializers/dotenv.rb` + `config/application.rb`** — the three-way
   interaction between `.env.<environment>`, git-crypt and Rails encrypted
   credentials, including which wins when they disagree. Highest-value first
   ingest: it is the thing newcomers get wrong, and it is currently spread across
   a README section, `docs/DEVELOPMENT.md` and shell config.

   > ⛔ **Read the resolution *logic*, never the credential *values*.** Do not
   > open `config/credentials/` — on an unlocked checkout it holds `*.key`
   > material and decrypted `*.yml.enc` contents, and the schema forbids both
   > from reaching a page. The same goes for any `.env*` file: cite
   > `.envrc`'s precedence logic by `path:line`, never a value it resolves to.
   > Describing *which* keys exist and *how* they are resolved is the goal;
   > their contents are never part of it.
2. **`docs/decisions/`** — existing ADRs. Ingesting these seeds the Decisions
   section and immediately reveals which decisions were never written down.
3. **`docs/DATABASE.md` + `db/`** — schema shape and migration conventions.
4. **`docs/DOCKER_COMPOSE.md` + `compose*.yml` + `Dockerfile.*`** — how the app
   is containerised per environment, and how that differs from Fly/Render.
5. **`app/` request path** — Rails → Inertia → React boundary; the highest-churn
   area and the one where `path:line` citations decay fastest, so a good test of
   whether staleness detection actually works.
6. **PR #289 / #290** — recent merged work on OmniAuth behind a Tailscale proxy
   and registry image pushes. Good test of ingesting a *discussion* rather than a
   file: the reasoning lives in review comments, not the diff.

> Ingest one source at a time and let `/wiki-lint` run between them. The pattern
> compounds — later ingests cross-link into earlier pages, which is where the
> value is. Batch-ingesting six sources produces six islands.

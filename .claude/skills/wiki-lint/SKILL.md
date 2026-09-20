---
name: wiki-lint
description: Health-check the CAMI wiki — stale citations, contradictions, orphans, wanted pages, index drift, and leaked secrets. Use when the user says "/wiki-lint", "lint the wiki", "check the wiki", "is the wiki still accurate", or after a run of ingests, a large merge, or a refactor that moved files.
---

# /wiki-lint — health-check the wiki

The bookkeeping humans abandon. Read
[`wiki/CLAUDE.md`](../../../wiki/CLAUDE.md) first — it defines staleness, the page
contract and the index entry format this checks against.

Because pages cite `path:line` plus a `verified_at` commit, most of this is
**mechanical rather than a judgement call**. Run the checks; don't eyeball it.

## Setup — run this first

Every check below depends on these helpers. Paste them into the shell once per
lint run.

The fence below is four backticks, not three: `index_links` has to match a
markdown fence, so its awk program contains three literal backticks and would
otherwise close its own code block.

````bash
# Frontmatter only — never the body. Checks that grep the whole file can be
# satisfied by a code sample or prose containing "status:", which is how a
# malformed page passes contract lint.
fm() { awk 'NR==1{if($0!="---") exit; next} /^---$/{exit} {print}' "$1"; }

# Citation paths, scoped to frontmatter. Note the range must be bounded by the
# end of the frontmatter: `sed -n '/^cites:/,/^[a-z_]*:/p'` over the whole file
# runs to EOF when `cites:` is the last field, and then swallows any indented
# "  - " bullet in the body as if it were a citation.
cites() { fm "$1" | sed -n '/^cites:/,$p' | sed -n 's/^[[:space:]]*-[[:space:]]*//p'; }

# A commit, not merely "some object". `git cat-file -e` is satisfied by a blob
# or a tree, and a non-commit does not fail quietly downstream — it fails loudly
# and wrongly. Measured on this repo with a blob in `verified_at`:
#
#   git rev-list --count <blob>..HEAD   -> 1309, the entire history, because the
#                                          non-commit exclusion is inert
#   git diff --quiet <blob>..HEAD -- p  -> exit 129 and 40 lines of git usage
#
# Exit 129 is non-zero, so `! git diff --quiet` reads as "this path changed":
# every cited path reports STALE, the bogus distance trips AGED, and the manifest
# equivalent reports SOURCE BEHIND — each wrapped in usage text. `^{commit}`
# peels an annotated tag and rejects anything that is not a commit.
is_commit() { git rev-parse --verify --quiet "${1}^{commit}" >/dev/null 2>&1; }

# index.md links, excluding fenced code blocks. index.md documents the entry
# format by *showing* one, so its own example link is not an index entry. Left
# in, it breaks the reverse check (a fresh scaffold reports the example slug as
# INDEXED BUT MISSING) and the forward one alike (a page whose slug matched the
# example would read as indexed on the strength of the illustration).
index_links() {
  awk '/^[[:space:]]*```/ { fenced = !fenced; next } !fenced' wiki/index.md
}
````

Every loop iterates via `find` rather than a `wiki/pages/*.md` glob: an unmatched
glob errors under zsh and expands to a literal path under bash, and an empty
`pages/` is a legitimate state (a freshly scaffolded wiki). `find` no-ops cleanly
in both shells.

## Checks

### 1. Broken citations — a cited path no longer exists

The most serious failure: the page makes claims about code that is gone.

```bash
find wiki/pages -name '*.md' -type f | while read -r page; do
  cites "$page" | while read -r path; do
    [ -z "$path" ] && continue
    git ls-files --error-unmatch "$path" >/dev/null 2>&1 || echo "BROKEN  $page -> $path"
  done
done
```

### 2. Stale citations — cited code changed since `verified_at`

```bash
STALE_AFTER=200 # commits; see the staleness rules in wiki/CLAUDE.md

find wiki/pages -name '*.md' -type f | while read -r page; do
  sha=$(fm "$page" | sed -n 's/^verified_at: *//p' | tr -d '"')
  [ -z "$sha" ] && { echo "NO verified_at  $page"; continue; }
  is_commit "$sha" || { echo "BAD verified_at  $page ($sha — not a commit)"; continue; }

  distance=$(git rev-list --count "$sha..HEAD" 2>/dev/null)

  # 2a. A cited path changed since the page was verified.
  cites "$page" | while read -r path; do
    [ -z "$path" ] && continue
    if ! git diff --quiet "$sha..HEAD" -- "$path" 2>/dev/null; then
      echo "STALE  $page -> $path ($distance commits behind)"
    fi
  done

  # 2b. The page is simply old. Without this, a page whose cited files happen not
  # to have changed stays `current` forever, however far behind it is — the third
  # staleness criterion in the contract would otherwise be unenforced.
  if [ "${distance:-0}" -gt "$STALE_AFTER" ]; then
    echo "AGED  $page ($distance commits behind, threshold $STALE_AFTER)"
  fi
done
```

### 3. Wanted pages — `[[links]]` with no target

Not errors: the wiki's own backlog, ranked by how many pages want them.

```bash
grep -rho '\[\[[a-z0-9-]*\]\]' wiki/pages/ | tr -d '[]' | sort | uniq -c | sort -rn |
  while read -r count slug; do
    [ -f "wiki/pages/$slug.md" ] || echo "WANTED  $slug (linked from $count page(s))"
  done
```

### 4. Orphans — pages nothing links to

Reachable only via `index.md`. Either they need inbound links or they don't belong.

```bash
find wiki/pages -name '*.md' -type f | while read -r page; do
  slug=$(basename "$page" .md)
  grep -rq "\[\[$slug\]\]" --include='*.md' wiki/pages/ || echo "ORPHAN  $slug"
done
```

### 5. Index drift — `index.md` out of sync with `pages/`

Both directions, matching the **exact** index entry format from `wiki/CLAUDE.md`:

```
- [<Title>](./pages/<slug>.md) — one-line summary
```

Matching the bare slug instead would be wrong in both directions: `grep -q auth`
is satisfied by an entry for `oauth-flow`, and an entry for `job-queueing` would
satisfy a page slugged `job-queue`. Match the link literally with `-F`.

Both directions read the index through `index_links`, never `wiki/index.md`
directly: the fenced example above is documentation, not an entry, and counting
it as one is wrong in both directions.

```bash
# Pages missing from the index
find wiki/pages -name '*.md' -type f | while read -r page; do
  slug=$(basename "$page" .md)
  index_links | grep -qF "](./pages/$slug.md)" || echo "UNINDEXED  $slug"
done

# Index entries with no page
index_links | grep -o '](\./pages/[a-z0-9-]*\.md)' | sed 's|](\./pages/||;s|\.md)||' |
  while read -r slug; do
    [ -f "wiki/pages/$slug.md" ] || echo "INDEXED BUT MISSING  $slug"
  done
```

### 6. Contract violations

Frontmatter-scoped, and including `cites` — a page with no citations otherwise
passes contract lint *and* evades both citation checks above, which is the one
combination that lets a page make unverifiable claims indefinitely.

```bash
find wiki/pages -name '*.md' -type f | while read -r page; do
  slug=$(basename "$page" .md)
  head -1 "$page" | grep -q '^---$' || { echo "NO FRONTMATTER  $page"; continue; }
  fm "$page" | grep -q "^slug: $slug$" || echo "SLUG MISMATCH  $page"
  for field in title kind status updated verified_at cites; do
    fm "$page" | grep -q "^$field:" || echo "MISSING $field  $page"
  done
  [ -z "$(cites "$page")" ] && echo "EMPTY cites  $page"
  grep -q '^## Open questions' "$page" || echo "NO Open questions SECTION  $page"
done
```

### 7. Unresolved contradictions, with age

The convention in `wiki/CLAUDE.md` requires a date on every contradiction
(`Unresolved as of YYYY-MM-DD`), which is what makes age reportable — a
contradiction open for months is a decision nobody is making.

```bash
grep -rn '⚠️ \*\*Contradiction:\*\*' wiki/pages/ | while IFS= read -r hit; do
  date_seen=$(printf '%s' "$hit" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
  if [ -z "$date_seen" ]; then
    echo "CONTRADICTION (undated — add 'Unresolved as of <date>')  $hit"
  else
    age=$(python3 -c "import datetime,sys;print((datetime.date.today()-datetime.date.fromisoformat(sys.argv[1])).days)" "$date_seen")
    echo "CONTRADICTION (${age}d open)  $hit"
  fi
done

grep -rl '^status: contested' wiki/pages/
```

### 8. Source freshness — manifest rows far behind `HEAD`

`wiki/sources/manifest.md` records the commit each source was read at. A source
whose commit is well behind `HEAD` may have changed since it was ingested.

The **Source** column is free text, not a path, so this cannot diff per-source
automatically — it reports distance and leaves the judgement to a human, which is
the honest limit of a markdown manifest.

```bash
sed -n 's/^| *\([0-9-]\{10\}\) *| *\([^|]*\)| *[^|]*| *\([0-9a-f]\{7,40\}\) *|.*/\1|\2|\3/p' \
  wiki/sources/manifest.md | while IFS='|' read -r date source sha; do
  is_commit "$sha" || { echo "BAD SHA in manifest  $sha ($source — not a commit)"; continue; }
  distance=$(git rev-list --count "$sha..HEAD" 2>/dev/null)
  [ "${distance:-0}" -gt 200 ] && echo "SOURCE BEHIND  $(echo "$source" | xargs) — $distance commits since $sha"
done
```

### 9. Leaked secrets — highest severity

The wiki is committed to a shared repository. A page must never contain a
credential value.

**The output of this check must never contain the value it found.** A bare
`grep -rni` prints the whole matching line, which copies the secret into your
terminal, this session's context, and anywhere the run gets pasted or logged —
the detector becomes a second exposure. Report the location and the matched
keyword; redact the value.

The scope is the whole of `wiki/`, not `pages/` and `sources/`. Everything under
it is committed — `index.md`, `log.md` and `templates/` included — and the rule
is about what reaches the repository, not about which subdirectory an agent was
writing to. Scanning the working tree rather than `git ls-files` is deliberate:
this runs *before* a commit, so a secret that is still untracked is exactly the
one worth catching.

Quoted forms — `"api_key": "sk-..."` in JSON, `token: 'abc123'` in YAML — put a
quote between the keyword and the separator, and another between the separator
and the value. A pattern that requires the keyword to be followed directly by
`[:=]` never reaches either quoted case, so both the grep and the redacting sed
allow one optional `"` or `'` on each side. The value side cannot just drop the
`<`-exclusion after the optional quote, either: `[^<[:space:]]` alone is
satisfied by the quote character itself, which would flag a quoted placeholder
like `"token": "<placeholder>"` as a hit. The alternation below requires the
character *after* an optional opening quote to be the real, non-`<` value.

```bash
# Location + keyword only. The sed stage rewrites the value away before it is
# ever printed, so no pipeline downstream of here can see it.
grep -rnIiE "(secret|password|token|api[_-]?key|master[_-]?key)[\"']?[[:space:]]*[:=][[:space:]]*([\"'][^<]|[^<[:space:]\"'])" \
     wiki/ \
  | sed -E "s/^([^:]*:[0-9]*:).*[^a-z_]?(secret|password|token|api[_-]?key|master[_-]?key)[\"']?[[:space:]]*[:=].*\$/\1 \2 = <redacted>/I"

# Already filename-only (-l): never prints key material.
grep -rlE 'BEGIN [A-Z ]*PRIVATE KEY' wiki/
```

Verified against a scratch fixture covering both quoted secret forms, an
unquoted secret, an unquoted placeholder, and a quoted placeholder, before
trusting this as the wiki-wide gate — the placeholder cases must stay silent:

```bash
tmp=$(mktemp)
printf '%s\n' \
  '  "api_key": "sk-live-abc123def456"' \
  "  token: 'abc123plain'" \
  '  password: plainvalue' \
  '  api_key: <REDACTED>' \
  '  "token": "<placeholder>"' \
  > "$tmp"
grep -rnIiE "(secret|password|token|api[_-]?key|master[_-]?key)[\"']?[[:space:]]*[:=][[:space:]]*([\"'][^<]|[^<[:space:]\"'])" "$tmp" \
  | sed -E "s/^([^:]*:[0-9]*:).*[^a-z_]?(secret|password|token|api[_-]?key|master[_-]?key)[\"']?[[:space:]]*[:=].*\$/\1 \2 = <redacted>/I"
# expect: lines 1-3 flagged (redacted), lines 4-5 silent
rm -f "$tmp"
```

Any hit: stop, and do not commit. Tell the user the **file and line** and what
kind of credential it looks like — never the value, not even when they ask to see
it; they can open the file themselves, and repeating it here would put it in one
more place. Treat a matched credential as compromised and needing rotation —
removing it from the working tree is not enough if it was ever committed.

## Reporting

Report grouped by severity, counts first:

1. **Leaked secrets** — stop everything
2. **Broken citations** — pages making claims about code that no longer exists
3. **Contract violations** — malformed pages, missing or empty `cites`
4. **Stale / aged citations** — with how far behind
5. **Unresolved contradictions** — with age in days
6. **Source freshness** — manifest rows far behind
7. **Index drift**
8. **Orphans**
9. **Wanted pages** — the backlog, ranked

## What to fix, and what to leave

**Fix without asking** — bookkeeping is the point of this skill:

- Index drift, in both directions, using the exact entry format.
- The **Wanted pages** section of `wiki/index.md`: rewrite it from check 3's
  output. `index.md` declares that section lint-maintained, so leaving it stale
  makes the committed index lie.
- Missing `## Open questions` sections, slug mismatches.
- `status:` corrected to `stale` where citations demonstrably changed.

**Report, do not fix:** contradictions (a human decides), broken citations
(needs someone who knows where the code went), orphans (deleting is a judgement
call), wanted pages themselves (that is `/wiki-ingest`'s job), empty `cites` on a
page whose claims you cannot verify.

Never mark a page `current` without actually re-verifying it against the code.
Flipping the field is not verification, and a wiki that lies confidently is worse
than one that admits staleness.

Then append to `wiki/log.md`:

```markdown
## <date> — lint — <n> issues (<n> fixed, <n> for review)

- **Commit:** <sha>
- **Notes:** what was fixed automatically, what needs a human
```

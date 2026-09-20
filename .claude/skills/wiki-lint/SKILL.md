---
name: wiki-lint
description: Health-check the CAMI wiki — stale citations, contradictions, orphans, wanted pages, index drift, and leaked secrets. Use when the user says "/wiki-lint", "lint the wiki", "check the wiki", "is the wiki still accurate", or after a run of ingests, a large merge, or a refactor that moved files.
---

# /wiki-lint — health-check the wiki

The bookkeeping humans abandon. Read
[`wiki/CLAUDE.md`](../../../wiki/CLAUDE.md) first — it defines staleness and the
page contract this checks against.

Because pages cite `path:line` plus a `verified_at` commit, most of this is
**mechanical rather than a judgement call**. Run the checks; don't eyeball it.

Every loop below iterates via `find` rather than a `wiki/pages/*.md` glob: an
unmatched glob errors under zsh and expands to a literal path under bash, and an
empty `pages/` is a legitimate state (a freshly scaffolded wiki). `find` no-ops
cleanly in both shells.

## Checks

### 1. Broken citations — a cited path no longer exists

The most serious failure: the page makes claims about code that is gone.

```bash
find wiki/pages -name '*.md' -type f | while read -r page; do
  sed -n '/^cites:/,/^[a-z_]*:/p' "$page" | sed -n 's/^  - //p' | while read -r path; do
    git ls-files --error-unmatch "$path" >/dev/null 2>&1 || echo "BROKEN  $page -> $path"
  done
done
```

### 2. Stale citations — cited code changed since `verified_at`

```bash
find wiki/pages -name '*.md' -type f | while read -r page; do
  sha=$(sed -n 's/^verified_at: *//p' "$page" | tr -d '"')
  [ -z "$sha" ] && { echo "NO verified_at  $page"; continue; }
  git cat-file -e "$sha" 2>/dev/null || { echo "BAD SHA  $page ($sha)"; continue; }
  sed -n '/^cites:/,/^[a-z_]*:/p' "$page" | sed -n 's/^  - //p' | while read -r path; do
    if ! git diff --quiet "$sha..HEAD" -- "$path" 2>/dev/null; then
      echo "STALE  $page -> $path ($(git rev-list --count "$sha..HEAD" 2>/dev/null) commits behind)"
    fi
  done
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

```bash
find wiki/pages -name '*.md' -type f | while read -r page; do
  slug=$(basename "$page" .md)
  grep -q "$slug" wiki/index.md || echo "UNINDEXED  $slug"
done
grep -o '(\./pages/[a-z0-9-]*\.md)' wiki/index.md | sed 's|(\./pages/||;s|\.md)||' |
  while read -r slug; do [ -f "wiki/pages/$slug.md" ] || echo "INDEXED BUT MISSING  $slug"; done
```

### 6. Contract violations

```bash
find wiki/pages -name '*.md' -type f | while read -r page; do
  slug=$(basename "$page" .md)
  head -1 "$page" | grep -q '^---$' || echo "NO FRONTMATTER  $page"
  grep -q "^slug: $slug$" "$page" || echo "SLUG MISMATCH  $page"
  for field in title kind status updated verified_at; do
    grep -q "^$field:" "$page" || echo "MISSING $field  $page"
  done
  grep -q '^## Open questions' "$page" || echo "NO Open questions SECTION  $page"
done
```

### 7. Unresolved contradictions

Report every one with its age. A contradiction open for months is a decision
nobody is making.

```bash
grep -rn '⚠️ \*\*Contradiction:\*\*' wiki/pages/
grep -rln '^status: contested' wiki/pages/
```

### 8. Leaked secrets — highest severity

The wiki is committed to a shared repository. A page must never contain a
credential value.

```bash
grep -rniE '(secret|password|token|api[_-]?key|master[_-]?key)[[:space:]]*[:=][[:space:]]*[^<[:space:]]' wiki/pages/ wiki/sources/
grep -rlE 'BEGIN [A-Z ]*PRIVATE KEY' wiki/
```

Any hit: stop, report it to the user immediately, and do not commit. Treat a
matched credential as compromised and needing rotation — removing it from the
working tree is not enough if it was ever committed.

## Reporting

Report grouped by severity, counts first:

1. **Leaked secrets** — stop everything
2. **Broken citations** — pages making claims about code that no longer exists
3. **Contract violations** — malformed pages
4. **Stale citations** — with how far behind
5. **Unresolved contradictions** — with age
6. **Index drift**
7. **Orphans**
8. **Wanted pages** — the backlog, ranked

## What to fix, and what to leave

**Fix without asking:** index drift, missing `Open questions` sections, slug
mismatches, `status:` corrected to `stale` where citations demonstrably changed.
Bookkeeping is the point of this skill.

**Report, do not fix:** contradictions (a human decides), broken citations
(needs someone who knows where the code went), orphans (may need deleting, which
is a judgement call), wanted pages (that is `/wiki-ingest`'s job).

Never mark a page `current` without actually re-verifying it against the code.
Flipping the field is not verification, and a wiki that lies confidently is worse
than one that admits staleness.

Then append to `wiki/log.md`:

```markdown
## <date> — lint — <n> issues (<n> fixed, <n> for review)

- **Commit:** <sha>
- **Notes:** what was fixed automatically, what needs a human
```

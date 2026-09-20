---
name: wiki-query
description: Answer a question about the CAMI codebase from the wiki first, then file a durable answer back as a page. Use when the user says "/wiki-query", "ask the wiki", "what does the wiki say about X", or asks a how-does-this-work question about this codebase that is worth answering once rather than every time.
---

# /wiki-query — answer from the wiki, then file the answer

The wiki exists so a question is answered *once*. Read
[`wiki/CLAUDE.md`](../../../wiki/CLAUDE.md) first — it is the schema.

The output of a query is two things: an answer for the user **and**, when the
answer was worth the effort, a page so nobody derives it again. Skipping the
second half is what makes knowledge bases die.

## Workflow

### 1. Ask the wiki before the code

```bash
cat wiki/index.md
grep -ril "<term>" wiki/pages/
```

Start with `index.md` — it is the map, and one line per page is usually enough to
tell you which pages matter.

### 2. Judge what you found

| Found | Do this |
|---|---|
| A page that answers it, `status: current` | Verify its `cites:` still hold (step 3), then answer |
| A page that answers it, `status: stale`/`contested` | Verify against code, then answer *and* refresh the page |
| Partial coverage | Answer from code, then **update** the page that should have covered it |
| Nothing | Answer from code, then create a page (step 5) |

Say plainly which case you were in. "The wiki already had this" and "I had to
read the code" are different answers, and the user needs to know which.

### 3. Trust but verify

A page's claims are only as current as its `verified_at`. Before repeating a
claim, check its citations still hold:

```bash
# Do the cited paths still exist?
git ls-files --error-unmatch <path> 2>/dev/null || echo "MOVED OR DELETED: <path>"

# Have they changed since the page was verified?
git diff --stat <verified_at>..HEAD -- <path>
```

If a cited path moved or changed, verify against the code before answering, and
fix the page. **Never repeat a stale claim as current** — a wiki that confidently
says wrong things is worse than no wiki.

### 4. Answer the user

Answer the question asked, at the length it deserves. Cite `path:line` so the
user can check you, and link the pages you drew on.

### 5. File the answer back

Judgement call — file when the answer is **durable** (still true next month) and
**cost something** to derive. Skip for one-off or transient questions; not
everything is a page.

- **Wiki was partial** → update the page that should have covered it, refreshing
  `updated:`, `verified_at:` and `cites:`.
- **Wiki had nothing** → create `wiki/pages/<slug>.md` from
  `wiki/templates/page.md`. For a question you answered, `kind: concept`. For one
  you *couldn't* answer, `kind: question`, recording what you ruled out — a
  documented dead end saves the next person the same hour.

Then add the line to `wiki/index.md`, and append to `wiki/log.md`:

```markdown
## <date> — query — <the question>

- **Source:** wiki pages consulted, plus any code read
- **Commit:** <sha>
- **Pages touched:** [[slug]] (created|updated)
- **Notes:** whether the wiki could answer it unaided
```

That last note is the metric that matters. Over time it tells you whether the
wiki is compounding or you are just reading code with extra steps.

### 6. Say what you filed

One line: what you updated or created, or why you filed nothing.

## Notes

- If you hit a contradiction between a page and the code, flag it on the page
  (`> ⚠️ **Contradiction:**`, `status: contested`) rather than quietly trusting
  the code. The disagreement is information.
- Never write secrets or credential values into a page.
- If answering required reading a whole subsystem, that is a signal the subsystem
  deserves an `/wiki-ingest`, not just a page. Say so.

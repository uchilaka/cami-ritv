---
title: Job queue
slug: job-queue
kind: concept # concept | entity | decision | runbook | question
status: current # current | stale | contested
updated: 2026-09-20
verified_at: 0000000 # commit sha this page's claims were checked against
cites:
  - config/queue.yml
  - app/jobs/application_job.rb
---

<!--
  Copy this file to ../pages/<slug>.md and replace everything. The frontmatter
  above is the contract — see ../CLAUDE.md. `slug` must equal the filename.

  Keep the section order: answer, then mechanism, then related, then questions.
  A reader who stops after the first paragraph should still have learned the
  useful thing.
-->

Jobs run through Solid Queue backed by the primary Postgres database, with each
queue mapped to a named worker pool. One paragraph, no preamble — this is what a
reader gets if they read nothing else.

## How it works

The mechanism, with citations rather than pasted code:

- Queues are declared in `config/queue.yml:4-18`; each entry names a pool.
- `app/jobs/application_job.rb:7` sets the global retry policy.

Quote at most a few lines, and only where the exact wording matters:

```ruby
# app/jobs/application_job.rb:7
retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 5
```

> ⚠️ **Contradiction:** `docs/DATABASE.md` claims jobs use a separate database;
> `config/database.yml:31` points the queue at the primary. Unresolved as of
> 2026-09-20.

## Related

- [[database-connections]] — the queue competes for the same pool
- [[deployment-secrets]] — workers need `RAILS_MASTER_KEY` at boot

## Open questions

- Is the `default` queue's concurrency limit deliberate, or inherited from the
  generator?

<!-- Leave this section empty if there are none, but do not delete it. An
     absent Open questions section reads as "nobody looked". -->

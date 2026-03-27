# 007. Use Solid Queue for Background Jobs

## Status
Accepted

## Context
The application requires background job processing for tasks such as sending emails, processing uploads, and heavy computations. Historically, Redis-backed systems like Sidekiq or Resque were the standard in Rails, but they require maintaining a separate Redis infrastructure.

## Decision
Use Solid Queue as the default ActiveJob backend for processing background tasks.

### Implementation Details
1. **Backend**: Solid Queue uses the existing PostgreSQL database to store and manage jobs.
2. **Configuration**: Configured in `config/environments/production.rb` and `config/queue.yml`.
3. **Usage**: Follows standard ActiveJob syntax.
   ```ruby
   class ProcessDataJob < ApplicationJob
     queue_as :default

     def perform(*args)
       # Do work
     end
   end
   ```
4. **Monitoring**: Utilizes `mission_control-jobs` for a UI dashboard to monitor queues, failed jobs, and retries.

## Consequences

### Positive
- **Simplified Infrastructure**: Eliminates the need to run and maintain a separate Redis instance.
- **Transactional Guarantees**: Enqueuing a job can be part of the same database transaction as the record creation, preventing race conditions.
- **Fewer Moving Parts**: Easier to test and deploy.

### Negative
- Increased load on the primary PostgreSQL database (though often negligible for most workloads).
- May not scale as high as Redis for extreme, hyper-scale queueing needs (e.g., tens of thousands of jobs per second).

## Notes
- Added: 2026-03-21
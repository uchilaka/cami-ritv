# Plan to Address Copilot Feedback from spike/twenty-crm

This plan covers resolving the code review feedback provided by Copilot on PR #245 (`spike/twenty-crm`).

## 1. Security & Credentials
- [ ] Fix `APP_SECRET` defaults in `docker-compose.yml` and `.env` (avoid insecure default values like `replace_me_with_a_random_string`, and provide better documentation/failure behaviors).
- [ ] Fix command injection vulnerabilities in `lib/commands/init_app.thor` (around `createdb`) and `lib/commands/restore_db.rb` (around `pg_restore` and `password` interpolation). Use secure execution mechanisms instead of shell interpolation.

## 2. Docker & Infrastructure Consistency
- [ ] Reconcile database host inconsistency: The CRM database host `CRM_DATABASE_HOST` defaults to `app-store` in some places but the new service is `crm-store`. Standardize to one or fix the service dependencies.
- [ ] Expose ports for `redis` and `crm-store` services in `docker-compose.yml` so they are accessible for development debugging (e.g. `16379:6379`).
- [ ] Fix inconsistent use of `NODE_ENV` vs `RAILS_ENV` in `docker-compose.yml` (specifically for volume mappings).
- [ ] Clarify `CRM_SERVICE_PORT` discrepancies (`16016` vs `16026`).

## 3. Code Cleanup & Refactoring
- [ ] Add explicit `require` statements in `lib/lar_city/base_cmd_stack.rb` for `LarCity::CLI::EnvHelpers` and `LarCity::CLI::OutputHelpers`.
- [ ] Remove commented out code and WIP code snippets in `lib/commands/lar_city/cli/base_cmd.rb`, `lib/commands/lar_city/cli/tunnel_cmd.rb`, and test files.
- [ ] Rename predicate methods like `is_enumerable?` to `enumerable?`.
- [ ] Remove useless assignments (e.g. `database` in `lib/commands/restore_db.rb`).

## 4. Test Coverage & RSpec Fixes
- [ ] Implement or remove pending tests (`skip: 'Pending validation'`) in `spec/lib/commands/restore_db_spec.rb`.
- [ ] Add missing test coverage for `InitApp`, `RestoreDb`, `BaseCmdStack`, and `ServicesCmd` (`list` command).
- [ ] Fix RSpec syntax from `it_should_behave_like` to `it_behaves_like` in `spec/lib/commands/lar_city/cli/output_helpers_spec.rb`.

## 5. Documentation
- [ ] Add method-level documentation for `wait_for_db` and `FormatHelperMethods`.

## Session Info
To resume the AI session that generated this plan, run:
```shell
gemini --resume 19f93089-d0d8-48b6-9eb6-64be1a9d14d5
```


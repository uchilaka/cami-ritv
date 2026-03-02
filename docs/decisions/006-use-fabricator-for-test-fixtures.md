# 006: Use Fabricator for Test Fixtures

## Status

Accepted

## Context

We need a consistent and efficient way to create test data (fixtures) for our RSpec tests. While FactoryBot is a popular choice, Fabricator offers a simpler, more concise syntax that can improve readability and reduce boilerplate.

## Decision

We will use the [Fabricator](https://fabricationgem.org/) gem for creating test fixtures in this project. All new tests should use Fabricator, and existing tests that use FactoryBot should be migrated to Fabricator when they are modified.

## Consequences

-   **Improved Readability:** Fabricator's syntax is often more straightforward than FactoryBot's, making tests easier to read and understand.
-   **Consistency:** Adopting a single fixture library ensures consistency across the test suite.
-   **Migration Effort:** Existing tests that use FactoryBot will need to be updated. This will be done on an as-needed basis to avoid a large, disruptive migration effort.


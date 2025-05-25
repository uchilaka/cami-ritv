# Documentation Standards

## Purpose

This document outlines the standards and practices for maintaining documentation in the project.

## Table of Contents

1. [Architectural Decision Records (ADRs)](#architectural-decision-records)
2. [Code Documentation](#code-documentation)
3. [API Documentation](#api-documentation)
4. [Process](#process)
5. [Tools](#tools)

## Architectural Decision Records

### Location

- Store ADRs in `docs/decisions/`
- Name files with a sequential number and a descriptive name: `###-short-description.md`
  - Example: `001-use-faraday-for-http.md`

### Format

Follow this template for new ADRs:

```markdown
# [Number]. [Short title]

## Status
[Proposed | Accepted | Deprecated | Superseded by [ADR-XXX](<url>)]

## Context
[What is the issue we're addressing?]

## Decision
[What did we decide?]

## Consequences
[What are the trade-offs and implications?]
```

## Code Documentation

### Ruby Code

- Use YARD for documentation
- Document all public methods and classes
- Include examples for complex methods

Example:

```ruby
# Calculates the total price including tax and discounts
# @param subtotal [Numeric] the pre-tax amount
# @param tax_rate [Numeric] the tax rate as a decimal (e.g., 0.08 for 8%)
# @return [Numeric] the total amount including tax
# @example
#   calculate_total(100, 0.08) #=> 108.0
def calculate_total(subtotal, tax_rate)
  subtotal * (1 + tax_rate)
end
```

### JavaScript/TypeScript

- Use JSDoc for documentation
- Include type information and examples

## API Documentation

- Document all API endpoints
- Include:
  - HTTP method and path
  - Request/response formats
  - Authentication requirements
  - Possible error responses
  - Example requests/responses

## Process

### Creating New Features

1. Create an ADR if the feature introduces new patterns or significant changes
2. Update relevant documentation before marking the feature as complete
3. Include documentation updates in the same PR as the code changes

### Modifying Existing Code

1. Update any documentation that becomes inaccurate
2. Add `@since` tags when introducing new public methods/classes
3. Deprecate rather than remove documentation for removed features

### Code Review

- Verify that documentation changes are included with code changes
- Reject PRs that introduce undocumented public APIs
- Check that examples in documentation match the implementation

## Tools

### Generation

- `yard` for Ruby documentation
- `jsdoc` for JavaScript documentation

### Linting

- `markdownlint` for Markdown files
- `rubocop` for Ruby documentation
- `eslint` for JavaScript documentation

### CI/CD

- Include documentation generation in the build process
- Validate documentation in PR checks
- Publish documentation on successful builds

## Review and Maintenance

- Review documentation during sprint retrospectives
- Schedule quarterly documentation audits
- Remove or update deprecated documentation

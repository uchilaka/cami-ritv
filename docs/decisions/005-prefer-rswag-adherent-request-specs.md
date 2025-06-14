# 5. Prefer RSwag-adherent Request Specs

Date: 2025-06-13

## Status

Accepted

## Context

When writing request specs for API endpoints, we need a consistent approach that allows for both thorough testing and clear, accurate API documentation. We currently have multiple approaches to writing request specs in our codebase, which leads to inconsistency and documentation challenges.

RSwag combines RSpec testing with Swagger documentation generation, providing a way to maintain accurate API documentation while ensuring thorough test coverage. Using RSwag conventions allows us to:

1. Generate up-to-date API documentation automatically from our tests
2. Enforce consistent request/response structures in our tests and documentation
3. Provide a single source of truth for both testing and documentation
4. Make our API more accessible to consumers through interactive Swagger UI

## Decision

We will prefer RSwag-adherent request specs for all API endpoints. Specifically:

1. Request specs should be written using RSwag conventions with the `swagger_helper`
2. Specs should include proper path, parameter, and response documentation
3. Tests should use the `run_test!` method provided by RSwag
4. API documentation should be generated using the `rswag:specs:swaggerize` rake task

For tests that don't fit neatly into the Swagger documentation format but are still necessary (such as edge cases or internal implementation details), we'll include them in a separate context within the same spec file, outside of the path/response blocks.

## Consequences

### Positive

- Consistent API testing approach across the codebase
- Self-updating API documentation that matches implementation
- Better developer experience for API consumers through interactive documentation
- Improved test consistency and readability
- Clear expectations for new API endpoints and their tests

### Negative

- Converting existing specs to RSwag format will require effort
- Some complex test scenarios may not fit well into the RSwag structure
- Developers need to understand both RSpec and OpenAPI/Swagger concepts

## Example

```ruby
# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V2::Webhooks::Notion::Events', type: :request do
  path '/api/v2/webhooks/notion/events' do
    post 'Creates a Notion webhook event' do
      tags 'Webhooks'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :event_params, in: :body, schema: {
        # Parameter schema
      }
      
      response '200', 'event processed' do
        let(:event_params) { # Example parameters }
        
        run_test! do
          expect(response).to have_http_status(:ok)
        end
      end
      
      response '422', 'invalid event data' do
        let(:event_params) { # Invalid parameters }
        
        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
  
  # Tests that don't fit into the Swagger format
  context 'when testing edge cases' do
    it 'handles special scenario' do
      # Test code
    end
  end
end
```

# 001. Use Faraday for HTTP Requests

## Status
Accepted

## Context
Our application needs to make HTTP requests to various external services. We needed a consistent, reliable, and maintainable way to handle these requests with proper error handling, retries, and response parsing.

## Decision
Use the Faraday gem as the standard HTTP client library for all network requests in the application.

### Implementation Details
1. **Shared HTTP Client**:
   - Located at `lib/lar_city/http_client.rb`
   - Pre-configured with retry logic and JSON parsing
   - Handles common error cases

2. **Configuration**:
   - Retry failed requests up to 3 times
   - Exponential backoff between retries
   - JSON request/response handling
   - Default timeouts and headers

3. **Usage**:
   ```ruby
   # Basic usage
   client = LarCity::HttpClient.client
   response = client.get('https://api.example.com/endpoint')
   
   # With custom headers
   client = LarCity::HttpClient.client
   client.headers['Authorization'] = 'Bearer token'
   response = client.get('https://api.example.com/secure')
   ```

## Consequences

### Positive
- **Consistency**: All HTTP requests follow the same patterns
- **Reliability**: Built-in retry logic improves resilience
- **Maintainability**: Centralized configuration is easier to update
- **Testability**: Faraday's test adapter makes it easy to mock responses

### Negative
- Additional dependency in the project
- Slight learning curve for developers unfamiliar with Faraday

### Risks
- Need to ensure all team members use the shared client
- Must update documentation when making changes to the client configuration

## Related Decisions
- [Documentation Standards](./../documentation-standards.md)

## Notes
- Added: 2025-05-24
- Last Updated: 2025-05-24

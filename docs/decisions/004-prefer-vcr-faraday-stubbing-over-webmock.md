# 004. Prefer VCR Cassettes or Faraday Stubbing Over WebMock

## Status
Proposed

## Context
Our test suite needs to make HTTP requests to external services, which can lead to:
- Flaky tests due to network issues
- Inconsistent test data
- Slow test execution
- Hitting rate limits on external APIs

While WebMock is a popular solution for stubbing HTTP requests, we've found that it can lead to brittle tests and doesn't provide good visibility into the actual API interactions.

## Decision
Prefer using VCR cassettes or Faraday's built-in test stubbing over WebMock for testing HTTP requests, with the following guidelines:

### 1. Primary Choice: VCR Cassettes
- Use VCR for recording and replaying real HTTP interactions
- Store cassettes in `spec/fixtures/vcr_cassettes/`
- Name cassettes after the test file and example group
- Keep cassettes in version control for CI consistency

Example:
```ruby
describe 'ExternalService' do
  it 'fetches data' do
    VCR.use_cassette('external_service/fetch_data') do
      # Test code that makes HTTP requests
    end
  end
end
```

### 2. Secondary Choice: Faraday Test Stubs
- For simple cases or when VCR is overkill
- Define stubs directly in the test file
- Keep stubs close to the test that uses them
- Use Faraday's test adapter for consistent stubbing

Example:
```ruby
let(:stubs) { Faraday::Adapter::Test::Stubs.new }
let(:conn) do
  Faraday.new do |builder|
    builder.adapter :test, stubs
  end
end

it 'handles errors' do
  stubs.get('/api/data') { [500, {}, 'Server Error'] }
  # Test error handling
end
```

### When to Use WebMock (Rare Cases)
- When testing code that doesn't use Faraday
- For testing low-level HTTP behavior
- When VCR or Faraday stubs aren't sufficient

## Consequences

### Positive
- **Deterministic Tests**: Tests are not affected by network conditions
- **Faster Tests**: No real network calls during test execution
- **Better Coverage**: VCR records real responses, catching API changes
- **Easier Debugging**: Cassettes provide a record of what was actually sent/received
- **Offline Testing**: Tests can run without an internet connection

### Negative
- **Cassette Management**: Need to manage and update cassettes when APIs change
- **Test Data Size**: Cassettes can bloat the repository size
- **Learning Curve**: Team needs to understand VCR and Faraday stubbing

### Risks
- **Stale Cassettes**: Tests might pass with outdated API responses
- **Sensitive Data**: Need to filter sensitive information from cassettes
- **Test Coupling**: Tests might become too tightly coupled to specific API responses

## Implementation
1. Add VCR to the Gemfile in the test group
2. Configure VCR in `spec/spec_helper.rb`
3. Document the testing approach in the project's testing guide
4. Provide examples of both VCR and Faraday stubbing patterns

## Related Decisions
- [001. Use Faraday for HTTP Requests](./001-use-faraday-for-http.md)

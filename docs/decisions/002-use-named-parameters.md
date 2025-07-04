# 002. Use Named Parameters in Ruby Methods

## Status
Accepted

## Context
Ruby 2.0+ introduced keyword arguments, which provide a clearer and more maintainable way to pass arguments to methods, especially when methods accept multiple parameters or have optional parameters.

## Decision
Use named parameters (keyword arguments) in Ruby methods when:
1. A method accepts more than two parameters
2. A method has optional parameters
3. The purpose of parameters isn't immediately clear from their order

### Implementation Guidelines

#### Preferred (using keyword arguments)
```ruby
def create_user(name:, email:, admin: false, **options)
  # Method implementation
end

# Clear call site
create_user(name: 'John', email: 'john@example.com', admin: true)
```

#### Avoid (positional parameters)
```ruby
def create_user(name, email, is_admin = false, options = {})
  # Method implementation
end

# Less clear call site
create_user('John', 'john@example.com', true, { send_welcome_email: true })
```

### When to Use Positional Arguments
Positional arguments are acceptable when:
1. The method has a single, obvious parameter
2. The method is a simple setter/getter
3. Following a well-known Ruby convention (e.g., `each { |item| }`)

### Documentation
Always document keyword arguments using YARD:

```ruby
# Creates a new user with the given attributes
#
# @param name [String] The user's full name
# @param email [String] The user's email address
# @param admin [Boolean] Whether the user has admin privileges (default: false)
# @param options [Hash] Additional options
# @option options [Boolean] :send_welcome_email Whether to send welcome email (default: true)
# @return [User] The created user
# @raise [ArgumentError] if name or email is missing
def create_user(name:, email:, admin: false, **options)
  # Implementation
end
```

## Consequences

### Positive
- Improved code readability at call sites
- Self-documenting method calls
- Easier to add new parameters without breaking existing code
- Better IDE support with parameter hints
- Prevents parameter order mistakes

### Negative
- Slightly more verbose method definitions
- May require updating existing code to adopt this pattern

### Risks
- Inconsistent usage across the codebase
- Potential performance impact (negligible in most cases)

## Related Decisions
- [001. Use Faraday for HTTP Requests](./001-use-faraday-for-http.md)

## Notes
- Added: 2025-05-24
- Last Updated: 2025-05-24

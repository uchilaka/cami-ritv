# 003. Use Thor for Task Implementations

## Status
Accepted

## Context
We need a consistent approach for implementing command-line tasks and administrative operations in our Rails application. While Rails provides Rake tasks, we've identified that Thor offers several advantages for our use case, particularly for complex command-line interfaces.

## Decision
Use Thor for implementing all command-line tasks and administrative operations, except when:

1. The operation is expected to be long-running or resource-intensive
2. The task processes large datasets that might require background processing
3. The operation is part of a scheduled job or background task
4. The task is primarily data migration or database-related (use Rails migrations instead)

### Implementation Guidelines

#### When to Use Thor
- Administrative commands (e.g., user management, system configuration)
- Data import/export operations (for small to medium datasets)
- System maintenance tasks
- Development utilities
- API interaction scripts

#### When to Use ActiveJob/Background Workers
- Long-running operations (> 30 seconds)
- Large data processing tasks
- Tasks that can be run asynchronously
- Operations that should be retried on failure

#### Directory Structure
```
lib/commands/
  lar_city/
    cli/
      base_cmd.rb       # Base command class
      main_cmd.rb       # Main command namespace
      user_cmd.rb       # User-related commands
      system_cmd.rb     # System administration commands
      data_cmd.rb       # Data-related commands
```

#### Example Implementation
```ruby
# lib/commands/lar_city/cli/user_cmd.rb
module LarCity
  module CLI
    class UserCmd < BaseCmd
      desc 'create', 'Create a new user'
      option :email, required: true, desc: 'User email'
      option :admin, type: :boolean, default: false, desc: 'Grant admin privileges'
      def create
        user = User.create!(
          email: options[:email],
          admin: options[:admin]
        )
        say "Created user: #{user.email}", :green
      rescue ActiveRecord::RecordInvalid => e
        say_error "Failed to create user: #{e.message}"
        exit 1
      end
    end
  end
end
```

#### Registering Commands
```ruby
# lib/commands/lar_city/cli/main_cmd.rb
require_relative 'base_cmd'
require_relative 'user_cmd'

module LarCity
  module CLI
    class MainCmd < BaseCmd
      desc 'user', 'Manage users'
      subcommand 'user', UserCmd
    end
  end
end
```

#### Command Execution
```bash
# Run a command
bundle exec thor lar_city:user:create --email=user@example.com --admin
```

## Consequences

### Positive
- Consistent command-line interface across the application
- Better code organization with subcommands and namespacing
- Built-in help system and command documentation
- Type conversion and validation of command-line arguments
- Reusable command components

### Negative
- Additional dependency (Thor gem)
- Slightly more complex than simple Rake tasks
- Requires proper namespacing to avoid command conflicts

### Risks
- Potential for command bloat if not properly organized
- Learning curve for developers unfamiliar with Thor
- Need to document available commands and their usage

## Related Decisions
- [001. Use Faraday for HTTP Requests](./001-use-faraday-for-http.md)
- [002. Use Named Parameters in Ruby Methods](./002-use-named-parameters.md)

## Notes
- Added: 2025-05-24
- Last Updated: 2025-05-24

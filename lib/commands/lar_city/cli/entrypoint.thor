# frozen_string_literal: true

require_relative 'base_cmd'
# require_relative 'datakit_cmd'
# require_relative 'devkit_cmd'
require_relative 'secrets_cmd'
require_relative 'services_cmd'
require_relative 'tunnel_cmd'
# require_relative 'accounts_cmd'

module LarCity
  module CLI
    class Entrypoint < BaseCmd
      namespace 'lx-cli'

      # desc 'accounts [SUBCOMMAND]', 'Manage accounts'
      # subcommand 'accounts', AccountsCmd

      desc 'secrets [SUBCOMMAND]', 'Manage the secrets in the environment credentials file'
      subcommand 'secrets', SecretsCmd

      desc 'services [SUBCOMMAND]', 'Manage application dockerized services'
      subcommand 'services', ServicesCmd

      # desc 'devkit [SUBCOMMAND]', 'A few developer tools for the project'
      # subcommand 'devkit', DevkitCmd
      #
      # desc 'datakit [SUBCOMMAND]', 'A few tools for managing application data stores'
      # subcommand 'datakit', DatakitCmd

      desc 'tunnel [SUBCOMMAND]', 'Manage the dev proxy tunnel (for testing the app with a public URL)'
      subcommand 'tunnel', TunnelCmd
    end
  end
end

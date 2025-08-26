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
      def self.system_bin_path
        '/usr/local/bin/lx-cli'
      end

      if File.symlink?(system_bin_path)
        namespace 'entrypoint'
      else
        namespace 'lx-cli'

        desc 'accounts [SUBCOMMAND]', 'Manage accounts'
        subcommand 'accounts', AccountsCmd

        desc 'secrets [SUBCOMMAND]', 'Manage the secrets in the environment credentials file'
        subcommand 'secrets', SecretsCmd

        desc 'services [SUBCOMMAND]', 'Manage application dockerized services'
        subcommand 'services', ServicesCmd

        desc 'devkit [SUBCOMMAND]', 'A few developer tools for the project'
        subcommand 'devkit', DevkitCmd

        desc 'datakit [SUBCOMMAND]', 'A few tools for managing application data stores'
        subcommand 'datakit', DatakitCmd

        desc 'tunnel [SUBCOMMAND]', 'Manage the dev proxy tunnel (for testing the app with a public URL)'
        subcommand 'tunnel', TunnelCmd
      end

      desc 'setup', 'Install LarCity CLI on your system'
      def setup
        FileUtils.rm(system_bin_path, verbose: verbose?) if File.symlink?(self.class.system_bin_path) && !dry_run?
        run 'ln -s', cli_exec_path, self.class.system_bin_path
        say <<~README
          LarCity CLI installed at #{self.class.system_bin_path}
          To see available commands, run: lx-cli -T
        README
      end

      desc 'uninstall', 'Uninstall LarCity CLI from your system'
      def uninstall
        FileUtils.rm(self.class.system_bin_path, verbose: verbose?) \
          if File.symlink?(self.class.system_bin_path) && !dry_run?
        say "LarCity CLI uninstalled from #{self.class.system_bin_path}."
      end

      private

      def cli_exec_path
        Rails.root.join('bin/thor').to_s
      end
    end
  end
end

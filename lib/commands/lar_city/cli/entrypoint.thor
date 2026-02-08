# frozen_string_literal: true

require_relative 'base_cmd'
require_relative 'datakit_cmd'
require_relative 'devkit_cmd'
require_relative 'secrets_cmd'
require_relative 'services_cmd'
require_relative 'tunnel_cmd'
require_relative 'accounts_cmd'

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

      define_sudo_option self, class_option: false
      desc 'setup', 'Install LarCity CLI on your system'
      def setup
        FileUtils.rm(system_bin_path, verbose: verbose?, noop: dry_run?) if File.symlink?(system_bin_path)
        cmd = ['ln -s', cli_exec_path, system_bin_path]
        # Prepend sudo if --sudo
        cmd.unshift('sudo') if options[:sudo]
        result = run(*cmd, inline: true)
        if verbose?
          say_info "Returned value: #{result.inspect}"
          say_highlight "Created symlink at #{system_bin_path} pointing to #{cli_exec_path}" if result
        end
        say <<~README
          LarCity CLI installed at #{system_bin_path}
          To see available commands, run: lx-cli -T
        README
      end

      define_sudo_option self, class_option: false
      desc 'uninstall', 'Uninstall LarCity CLI from your system'
      def uninstall
        if !File.symlink?(system_bin_path) && !dry_run?
          say_warning "LarCity CLI is not installed at #{system_bin_path}."
          return
        end

        result =
          if options[:sudo]
            run('sudo', 'rm', system_bin_path, inline: true)
          else
            FileUtils.rm(system_bin_path, noop: dry_run?, verbose: verbose?)
          end
        say "LarCity CLI uninstalled from #{system_bin_path}." if result || dry_run?
      end

      no_commands do
        delegate :system_bin_path, to: :class
      end

      private

      def cli_exec_path
        Rails.root.join('bin/thor').to_s
      end
    end
  end
end

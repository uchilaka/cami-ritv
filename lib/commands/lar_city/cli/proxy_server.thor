# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity
  module CLI
    class ProxyServer < BaseCmd
      def self.server_config_path
        File.join(nginx_config_path, 'servers')
      end

      def self.nginx_config_path
        '/opt/homebrew/etc/nginx'
      end

      no_commands do
        include ControlFlowHelpers
      end

      namespace :'proxy-server'

      define_sudo_option self, class_option: false
      desc 'setup', 'Set up the application proxy server'
      def setup
        # Remove existing symlink if it exists and is a symlink, to avoid errors when creating a new one
        if File.symlink?(server_config_target_file)
          FileUtils.rm(server_config_target_file, verbose: verbose?,
                                                  noop: pretend?)
        end
        # Create the symlink from the source config file to the nginx config directory, using sudo if --sudo is specified
        cmd = ['ln -s', server_config_source_file, server_config_target_file]

        unless File.exist?(server_config_source_file)
          message = <<~ERROR.squish
            Source server config file not found at #{server_config_source_file}.
            Please run 'lx-cli proxy-server init' to generate the necessary config files.
          ERROR
          say_error message
          return
        end

        # Prepend sudo if --sudo
        cmd.unshift('sudo') if sudo?
        result = run(*cmd, inline: true)
        if verbose?
          say_info "Returned value: #{result.inspect}"
          say_highlight "Created symlink at #{server_config_path} pointing to #{server_config_source_file}" if result
        end
        local_dev_clause = <<~MSG.squish
          Ensure that your hosts file is configured to point the relevant domains
          to the configured CAMI application port running on your local machine -
          see the #{server_config_source_file} for server configuration details).
        MSG
        message = <<~MSG.squish
          The LarCity CAMI proxy server configuration was installed at #{server_config_target_file}.

          #{Rails.env.development? ? local_dev_clause : ''}
        MSG
        say_success message
        kick_nginx_service
      end

      desc 'uninstall', 'Uninstall the application proxy server'
      def uninstall
        unless File.symlink?(server_config_source_file)
          say_error "No symlink found at #{server_config_target_file} to remove."
          return
        end

        result = FileUtils.rm(server_config_target_file, noop: pretend?, verbose: verbose?)
        say_info "Returned value: #{result.inspect}" if verbose?
        say_success <<~MSG.squish
          The LarCity CAMI proxy server configuration was uninstalled from #{server_config_target_file}.
        MSG
        kick_nginx_service
      end

      desc 'init', 'Generate the necessary config files for the application proxy server'
      def init
        crud_action = File.exist?(server_config_source_file) ? :update : :create
        say_error <<~MSG.squish
          Not yet implemented - please #{crud_action} the proxy server config file
          at the following path: #{server_config_source_file}
        MSG
      end

      no_commands do
        delegate :server_config_path, to: :class

        def kick_nginx_service
          run 'brew services restart nginx', inline: true
          run 'brew services info nginx', inline: true
        end
      end

      private

      def server_config_source_file
        Rails.root.join('.nginx', detected_environment, 'conf.d', 'servers.conf').to_s
      end

      def server_config_target_file
        File.join(server_config_path, 'cami.conf')
      end
    end
  end
end

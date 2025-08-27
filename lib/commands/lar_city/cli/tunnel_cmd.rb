# frozen_string_literal: true

require_relative 'base_cmd'
require 'open3'

module LarCity
  module CLI
    # Manage NGROK tunnels for dev testing of the app and rails API
    class TunnelCmd < BaseCmd
      namespace 'tunnel'

      desc 'init', 'Initialize ngrok config for the project'
      def init
        if Rails.env.test?
          say 'Skipping initialization of ngrok config in test environment.', Color::RED
          return
        end

        # Process each NGROK config file template found in the config directory
        for_each_proxy_config_file(force: true) do |template_file, config_file_name|
          # Process an ERB config file if one is found
          if config_file_exists?(name: config_file_name)
            say "ngrok config already exists at #{config_file(name: config_file_name)}.", Color::YELLOW
            next
          end

          puts 'Processing ngrok config ERB...'
          yaml_config = ERB.new(File.read(template_file)).result
          puts "Writing ngrok config to #{config_file(name: config_file_name)}"
          File.write config_file(name: config_file_name), yaml_config unless dry_run?
        end
      end

      desc 'open_all', 'Open ngrok tunnels for the project'
      def open_all
        if auth_token_nil?
          say_info <<~ERROR
            No ngrok auth token found. Please set NGROK_AUTH_TOKEN in your environment.#{' '}
            You will need an ngrok account to use this CLI command.#{' '}
            See https://dashboard.ngrok.com/get-started/your-authtoken for more information.
          ERROR

          return
        end

        # TODO: Make sure this works without issues on macOS
        invoke :init, [], verbose: Rails.env.development?

        if verbose?
          say_info <<~BANNER
            Starting ngrok tunnels for #{project_root}...
          BANNER
        end

        if proxy_config_files.empty? && !dry_run?
          say_info <<~ERROR
            No ngrok config files found. Please create one at #{app_config_file} or #{profile_config_file}.
          ERROR

          return
        end

        if windows? || linux?
          bottom_bar = '============================================================================'
          os_banner = " OS DETECTED: #{human_friendly_os_name.upcase} "
          top_bar_ends = '=' * ((bottom_bar.length - os_banner.length) / 2.0)
          launch_msg = <<~MSG

            #{top_bar_ends} OS DETECTED: #{human_friendly_os_name} #{top_bar_ends}
            Your dev proxy tunnel is about to launch via a Docker container.

            Visit your NGROK dashboard to view information on available endpoints:
            https://dashboard.ngrok.com/endpoints?sortBy=updatedAt&orderBy=desc
            ============================================================================

          MSG
          say launch_msg, :yellow
          run 'docker compose up tunnel'
        else
          run 'ngrok start --all',
              (proxy_config_files.empty? ? nil : "--config=#{proxy_config_files.join(',')}")
        end
      end

      no_commands do
        def for_each_proxy_config_file(force: false, &)
          Dir[Rails.root.join('config', 'ngrok*.yml.erb')].each do |config_file_template|
            file_name = config_file_from(template: config_file_template)
            next if config_file_exists?(name: file_name) && !force

            yield config_file_template, file_name
          end
        end

        def proxy_config_files
          unless defined?(@proxy_config_files)
            # TODO: Check for ngrok config file(s) and exit if they don't exist
            @proxy_config_files = []
            if profile_config_file.present? && File.exist?(profile_config_file)
              @proxy_config_files << profile_config_file
            end
            @proxy_config_files << app_config_file if app_config_file.present? && File.exist?(app_config_file)
          end
          @proxy_config_files || []
        end

        def app_config_file
          config_file(name: 'ngrok.yml')
        end

        def profile_config_file
          home_dir = Dir.home || ENV.fetch('USERPROFILE', nil)
          return nil unless home_dir

          "#{home_dir}/.ngrok2/ngrok.yml"
        end
      end

      private

      def auth_token_nil?
        ENV.fetch('NGROK_AUTH_TOKEN', nil).nil?
      end

      def project_root
        return @project_root if @project_root

        @project_root = Rails.root.to_s
        if verbose?
          puts <<~CMD
            ===========================================================================
               Project root: #{project_root}
            ===========================================================================
          CMD
        end

        @project_root
      end

      def has_realpath_cmd?
        @has_realpath_cmd ||= system('command -v realpath')
      end

      def has_python_3?
        @has_python_3 ||= system('command -v python3')
      end
    end
  end
end

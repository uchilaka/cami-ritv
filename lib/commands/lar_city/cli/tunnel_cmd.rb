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
        Dir[Rails.root.join('config', 'ngrok*.yml.erb')].each do |config_file_template|
          next unless File.exist?(config_file_template)

          file_name = File.basename(config_file_template, File.extname(config_file_template))
          # Process an ERB config file if one is found
          if config_file_exists?(name: file_name)
            say "ngrok config already exists at #{config_file(name: file_name)}.", Color::YELLOW
            next
          end

          puts 'Processing ngrok config ERB...'
          yaml_config = ERB.new(File.read(config_file_template)).result
          puts "Writing ngrok config to #{config_file(name: file_name)}"
          File.write config_file(name: file_name), yaml_config unless dry_run?
        end
      end

      desc 'open_all', 'Open ngrok tunnels for the project'
      def open_all
        if auth_token_nil?
          puts <<~ERROR
            No ngrok auth token found. Please set NGROK_AUTH_TOKEN in your environment.#{' '}
            You will need an ngrok account to use this CLI command.#{' '}
            See https://dashboard.ngrok.com/get-started/your-authtoken for more information.
          ERROR

          return
        end

        # TODO: Make sure this works without issues on macOS
        invoke :init, [], verbose: Rails.env.development?

        # TODO: Check for ngrok config file(s) and exit if they don't exist
        config_files = []
        app_config_file = File.join(project_root, 'config', 'ngrok.yml')
        profile_config_file = ENV.fetch('NGROK_PROFILE_CONFIG_PATH', nil)
        config_files << profile_config_file if profile_config_file.present? && File.exist?(profile_config_file)
        config_files << app_config_file if app_config_file.present? && File.exist?(app_config_file)

        if verbose?
          puts <<~BANNER
            Starting ngrok tunnels for #{project_root}...
          BANNER
        end

        if config_files.empty?
          puts <<~ERROR
            No ngrok config files found. Please create one at #{app_config_file} or #{profile_config_file}.
          ERROR

          exit 1
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
              "--config=#{config_files.join(',')}"
        end
      end

      private

      def config_file(name: 'ngrok.yml')
        Rails.root.join('config', name).to_s
      end

      def config_file_exists?(name: 'ngrok.yml')
        current_config_file = config_file(name:)
        if Dir.exist?(current_config_file)
          raise StandardError, <<~ERROR_MSG
            #{current_config_file} is a directory - it should be a file. \
            This can result if you attempted to start your app (dockerized) services \
            before the app has had the chance to process the NGROK templates \
            and setup your configuration files. The root cause is docker compose \
            attempting to mount a file that doesn't exist (which creates a folder \
            by default). Delete the directory and re-try the command.
          ERROR_MSG
        end

        File.exist?(current_config_file)
      end

      def auth_token_nil?
        ENV.fetch('NGROK_AUTH_TOKEN', nil).nil?
      end

      def project_root
        return @project_root if @project_root

        # project_rel_path = File.expand_path('../../..', __dir__)
        # if has_realpath_cmd?
        #   project_root = `realpath "#{project_rel_path}"`
        # elsif has_python_3?
        #   project_root = `python3 -c "import os; print(os.path.realpath('#{project_rel_path}'))"`
        # else
        #   puts 'realpath could not be found. Tunnel will not be opened.'
        #   exit 1
        # end
        #
        # if project_root.empty?
        #   puts 'realpath could not be found. Tunnel will not be opened.'
        #   exit 1
        # end
        #
        # @project_root = project_root.strip!
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

# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity
  module CLI
    class ServicesCmd < BaseCmd
      namespace 'services'

      class_option :profile,
                   type: :string,
                   desc: 'The profile to use for the command',
                   enum: %w[all essential batteries-included],
                   default: 'batteries-included'

      def self.add_port_option(
        desc:,
        long_desc: I18n.t('commands.services.lookup.options.port.long_desc'),
        required: false
      )
        option :port,
               type: :string,
               long_desc:, desc:, required:
      end

      option :force,
              desc: 'Force overwrite of existing daemon config',
              type: :boolean,
              default: false
      desc 'daemonize', 'Run a command to setup the app service as a background daemon process'
      def daemonize
        if Rails.env.test?
          say 'Skipping daemonize in test environment.', :red
          return
        end

        plist_file_template = Rails.root.join('config', 'com.larcity.cami.plist.erb').to_s
        file_name = config_file_from(template: plist_file_template)
        plist_file_path = config_file(name: file_name)
        # Process the ERB template
        if !dry_run? && config_file_exists?(name: file_name) && !options[:force]
          say "Daemon config already exists at #{plist_file_path}.", :yellow
          print_line_break
          say_info daemonize_guide(plist_file_path:)
          return
        end

        if options[:force]
          force_msg = <<~WARNING
            **************************************************************************
            *  WARNING: Any existing plist configuration file(s) will be overwritten *
            **************************************************************************
          WARNING
          say force_msg, Color::YELLOW
        end

        say 'Processing daemon config ERB...'
        plist_config = ERB.new(File.read(plist_file_template)).result
        say "Writing daemon config to #{plist_file_path}", :yellow
        File.write plist_file_path, plist_config unless dry_run?
        print_line_break

        # Make the plist file executable
        FileUtils.chmod '+x', plist_file_path, verbose: verbose?, noop: dry_run?

        # Symlink the plist file to /Library/LaunchAgents for system-wide daemons
        launch_agents_path = '/Library/LaunchDaemons'
        symlink_path = File.join(launch_agents_path, file_name)
        # FileUtils.ln_sf plist_file_path, symlink_path, verbose: verbose?, noop: dry_run?
        run 'sudo', 'ln', '-svf', plist_file_path, symlink_path

        if verbose?
          say_info daemonize_guide(plist_file_path: symlink_path)
          print_line_break
        end

        say 'Loading the daemon with launchctl...', :yellow
        run 'sudo', 'launchctl', 'load', '-w', symlink_path
        print_line_break
        say_success 'Daemon loaded. You can manage it using launchctl commands.'
        print_line_break
        say_success daemonize_guide(plist_file_path: symlink_path)
      rescue StandardError => e
        puts "Error setting up daemon: #{e.message}"
      end

      add_port_option(desc: I18n.t('commands.services.lookup.options.port.short_desc'))
      desc 'lookup', I18n.t('commands.services.lookup.short_desc')
      long_desc I18n.t('commands.services.lookup.long_desc')
      def lookup
        # Listening TCP ports: sudo lsof -nP -iTCP -sTCP:LISTEN
        # Specific TCP port: sudo lsof -i tcp:<port-number>
        # List PIDs for multiple ports: sudo lsof -i -P -n | grep -E ':(3036|16006)\b'
        # List PIDs for multiple ports (only TCP listening): sudo lsof -iTCP -sTCP:LISTEN -P -n | grep -E ':(3036|16006)\b'
        if configured_ports.blank?
          say 'No configured ports found. Please ensure your environment variables are set correctly.', :red
          return
        end

        if port.blank? && !Flipper.enabled?(:feat__lookup_by_configured_ports)
          say_highlight I18n.t('commands.services.lookup.no_port_specified_msg')
          return
        end

        if port.blank?
          lookup_by_configured_ports
        else
          # cmd = lookup_listening_ports_command port
          cmd = lookup_all_listening_ports_command
          say_highlight "Looking up service listening on #{port}"
          output = []
          # Example output:
          # COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
          # node    1234  user   22u  IPv4 25812      0t0  TCP *:3000 (LISTEN)
          # python  5678  user   10u  IPv4 25814      0t0  TCP *:8000 (LISTEN)
          run 'sudo', cmd, eval: true do |line|
            parts = line.split
            next if parts.length < 9 # Skip lines that don't have enough parts
            next if parts.first == 'COMMAND' # Skip header line

            listening_port = parts[8]
            if /[\.:]#{port}$/.match?(listening_port)
              output << {
                command: parts[0],
                pid: parts[1],
                user: parts[2],
                port: listening_port,
              }
            end
          end
          if output.blank?
            say_info "No service found listening on #{port}"
          else
            # TODO: format CLI output nicely using a table
            ap output
          end
        end
      rescue StandardError => e
        puts "Error looking up PID: #{e.message}"
      end

      add_port_option(desc: I18n.t('commands.services.kill.options.port.short_desc'), required: true)
      desc 'kill', I18n.t('commands.services.kill.short_desc')
      long_desc I18n.t('commands.services.kill.long_desc')
      def kill
        # TODO: pending implementation
      end

      option :pid,
             type: :string,
             desc: 'The PID of the process to kill',
             required: true
      desc 'kill_process', I18n.t('commands.services.kill_process.short_desc')
      long_desc I18n.t('commands.services.kill_process.long_desc')
      def kill_process
        result = run 'kill -9', options[:pid]
        say_highlight I18n.t('commands.services.kill_process.completed_msg', pid: options[:pid]) if result.nil?
      end

      option :database,
             type: :boolean,
             desc: 'Use the database service',
             default: false
      desc 'connect', 'Connect to a service'
      def connect
        if service_name.nil?
          puts 'Please specify a service to connect to.'
          return
        end

        run 'docker compose',
            'exec',
            service_name,
            service_connect_command
      rescue StandardError => e
        puts "Error connecting to service: #{e.message}"
      end

      desc 'start', 'Start the services'
      def start
        run 'docker compose',
            profile_clause,
            'up --detach',
            '&&',
            'docker compose',
            profile_clause,
            'logs --follow --since 5m'
      end

      desc 'logs', 'Show the logs of the services'
      def logs
        run 'docker compose',
            profile_clause,
            'logs --follow --since 5m'
      end

      desc 'stop', 'Stop the services'
      def stop
        run 'docker compose',
            profile_clause,
            'stop'
      end

      desc 'teardown', 'Stop and remove the services'
      def teardown
        run 'docker compose',
            profile_clause,
            'down --remove-orphans --volumes'
      end

      no_commands do
        protected

        def daemonize_guide(plist_file_path:)
          user_guide = I18n.t('commands.services.daemonize.user_guide', plist_file_path:)
          macos_guide = I18n.t('commands.services.daemonize.macos_guide', user_guide:)
          return macos_guide if mac?

          user_guide
        end

        def lookup_by_configured_ports
          if configured_ports.blank?
            say 'No configured ports found. Please ensure your environment variables are set correctly.', :red
            return
          end

          cmd = lookup_listening_ports_command(*configured_ports)
          say_highlight "Looking up services listening on configured ports: #{configured_ports.join(', ')}"
          result = run 'sudo', cmd, eval: true
          if result.nil?
            say_highlight 'No services found listening on configured ports.'
          else
            # TODO: format CLI output nicely using a table
            say_info result
          end
        end

        def lookup_listening_ports_command(*ports)
          raise ArgumentError, 'No ports specified for lookup' if ports.blank?

          # To extract just the port numbers from the output of printenv | grep PORT,
          # we can use awk and grep with a regex to match only the numbers:
          # ```shell
          # printenv | grep PORT | awk -F= '{print $2}' | grep -oE '[0-9]+'
          # ```
          match_pattern = "\\b#{ports.join('|')}\\b"
          "#{lookup_all_listening_ports_command} | grep -E '#{match_pattern}'"
        end

        def lookup_all_listening_ports_command
          'lsof -iTCP -sTCP:LISTEN -P -n'
        end

        private

        def service_connect_command
          if use_database_service?
            return [
              'psql -h db.cami.larcity',
              '--port 5432',
              "-U #{ENV.fetch('APP_DATABASE_USER')}",
              ENV.fetch('APP_DATABASE_NAME'),
            ].join(' ')
          end

          'bash'
        end

        def use_database_service?
          options[:database]
        end

        def service_name
          return 'app-store' if use_database_service?

          raise ArgumentError, 'Could not determine service name'
        end

        def profile_clause
          "--profile #{options[:profile]}"
        end

        def docker_compose_config_file
          Rails.root.join('docker-compose.yml').to_s
        end

        def configured_ports
          @configured_ports ||=
            begin
              result = `printenv | grep PORT | awk -F= '{print $2}' | grep -oE '[0-9]+'`
              result.split("\n").map(&:strip).reject(&:empty?)
            end
        end

        def port
          @port ||= options[:port]
        end
      end
    end
  end
end

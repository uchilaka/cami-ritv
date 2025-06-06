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
                   default: 'all'

      class_option :pid,
                   type: :string,
                   desc: 'The PID of the process to kill',
                   required: true
      desc 'kill_process', I18n.t('commands.services.kill_process.short_desc')
      long_desc I18n.t('commands.services.kill_process.long_desc')
      def kill_process
        result = run 'kill -9', options[:pid]
        say_highlight I18n.t('commands.services.kill_process.completed_msg', pid: options[:pid]) if result.nil?
      end

      method_option :database,
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
      end
    end
  end
end

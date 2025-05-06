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

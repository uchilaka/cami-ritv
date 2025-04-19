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

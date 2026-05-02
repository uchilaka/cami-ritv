# frozen_string_literal: true

# See https://stackoverflow.com/a/837593/3726759
app_path = File.join(Dir.pwd, 'app')
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'thor/group'
require 'awesome_print'
require 'concerns/operating_system_detectable'
require 'lar_city/cli/utils'
require 'lar_city/cli/env_helpers'
require 'lar_city/cli/output_helpers'
require 'lar_city/cli/interruptible'
require 'lar_city/cli/reversible'
require 'lar_city/cli/runnable'
require 'pg'

module LarCity
  module BaseCmdStack
    def self.included(base)
      base.extend(ClassMethods)

      # TODO: Is this "no_commands" block wrapper necessary?
      base.no_commands do
        base.include OperatingSystemDetectable
        base.include LarCity::CLI::EnvHelpers
        base.include LarCity::CLI::OutputHelpers

        base.define_env_options
        base.define_output_options
      end

      # TODO: Is this "no_commands" block wrapper necessary?
      base.no_commands do
        base.include LarCity::CLI::Interruptible
        base.include LarCity::CLI::Reversible
        base.include LarCity::CLI::Runnable
        base.include InstanceMethods
      end
    end

    module ClassMethods
      def exit_on_failure?
        true
      end
    end

    module InstanceMethods
      protected

      def wait_for_db(target: :primary, max_attempts: 30, delay: 2)
        if pretend?
          say_warning 'Pretend mode enabled - skipping database connection check.'
          return
        end

        say_highlight "Waiting for #{target} database service to become available..."

        attempts = 0
        begin
          healthy = db_health_check?(target:)
          result = ActiveRecord::Base.connection.execute('SELECT version();')[0]
          {
            engine: ActiveRecord::Base.connection.adapter_name,
            healthy:, version: result['version'],
          }
        rescue ActiveRecord::DatabaseConnectionError, ActiveRecord::NoDatabaseError => e
          attempts += 1
          raise e if attempts >= max_attempts

          sleep delay
          retry
        end
      end

      def db_health_check?(target: :primary)
        say_debug "DB target -> #{database_config_from_env[target].inspect}"
        user, host, port, db_name =
          database_config_from_env[target].values_at(:user, :host, :port, :name)
        raise ArgumentError, 'db_name is required' if db_name.blank?

        result =
          run "pg_isready --port #{port}",
              "-U #{user}", "-h #{host}", "-d #{db_name}",
              inline: true, eval: true
        %r{accepting connections}.match?(result)
      end

      def database_config_from_env
        {
          primary: {
            host: ENV.fetch('APP_DATABASE_HOST'),
            port: ENV.fetch('APP_DATABASE_PORT'),
            user: ENV.fetch('APP_DATABASE_USER'),
            name: ENV.fetch('APP_DATABASE_NAME_PRIMARY', "sails_#{detected_environment}"),
          },
          crm: crm_database_config_from_env,
        }
      end

      def crm_database_config_from_env
        {
          host: ENV.fetch('PG_DATABASE_HOST', 'crm-store'),
          port: ENV.fetch('PG_DATABASE_PORT', '5432'),
          user: ENV.fetch('APP_DATABASE_USER', 'postgres'),
          name: ENV.fetch('APP_DATABASE_NAME_CRM', "twenty_crm_#{detected_environment}"),
        }
      end
    end
  end
end

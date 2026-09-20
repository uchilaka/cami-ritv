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

      # Binds ActiveRecord::Base to +target+ for the duration of the block, then
      # restores whatever it was bound to before.
      #
      # Rails' `db:*` tasks — and the data_migrate gem's `data:migrate`, which has
      # no target of its own — all operate on whatever database ActiveRecord::Base
      # happens to be bound to. `db:create:*` is the trap: it binds the process to
      # the postgres maintenance database to issue CREATE DATABASE and only rebinds
      # to the target afterwards. When the database already exists the CREATE raises
      # DatabaseAlreadyExists, Rails swallows it *before* that rebind, and every
      # task invoked later in the same process inherits the maintenance binding.
      # See LAR-335.
      def with_database(target: :primary)
        original_db_config = ActiveRecord::Base.connection_db_config
        db_config =
          ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: target.to_s)
        raise ArgumentError, "No #{Rails.env} database configured for target: #{target}" if db_config.nil?

        ActiveRecord::Base.establish_connection(db_config)
        yield
      ensure
        ActiveRecord::Base.establish_connection(original_db_config) if original_db_config
      end

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

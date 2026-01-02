# frozen_string_literal: true

# See https://stackoverflow.com/a/837593/3726759
app_path = File.join(Dir.pwd, 'app')
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'thor/group'
require 'awesome_print'
require 'concerns/operating_system_detectable'
require 'lar_city/cli/utils'
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
      end

      LarCity::CLI::EnvHelpers.define_class_options(base)
      LarCity::CLI::OutputHelpers.define_class_options(base)

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
      def wait_for_db(max_attempts: 30, delay: 2)
        if pretend?
          say_warning 'Pretend mode enabled - skipping database connection check.'
          return
        end

        attempts = 0
        begin
          result = ActiveRecord::Base.connection.execute("SELECT version();")[0]
          {
            engine: ActiveRecord::Base.connection.adapter_name,
            version: result['version']
          }
        rescue PG::ConnectionBad, ActiveRecord::NoDatabaseError => e
          attempts += 1
          raise e if attempts >= max_attempts

          sleep delay
          retry
        end
      end
    end
  end
end

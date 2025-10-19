# frozen_string_literal: true

# See https://stackoverflow.com/a/837593/3726759
app_path = File.join(Dir.pwd, 'app')
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'thor'
require 'awesome_print'
require 'concerns/operating_system_detectable'
require 'lar_city/cli/utils'
require 'lar_city/cli/interruptible'
require 'lar_city/cli/reversible'
require 'lar_city/cli/runnable'

# Conventions for command or task implementation classes:
# - Use the namespace method to define a namespace for the Thor class.
# - Use the desc method to define a description for the command.
# - Use the method_option method to define options for the command.
# - Use the say method to output text to the console.
# - All text verbose output should be in Thor::Shell::Color::MAGENTA.
module LarCity
  module CLI
    class BaseCmd < Thor
      def self.exit_on_failure?
        true
      end

      def self.define_class_options
        class_option :dry_run,
                     type: :boolean,
                     aliases: %w[-d --pretend --preview],
                     desc: 'Dry run',
                     default: false
        class_option :environment,
                     type: :string,
                     aliases: '--env',
                     desc: 'Environment',
                     required: false
        class_option :verbose,
                     type: :boolean,
                     aliases: '-v',
                     desc: 'Verbose output',
                     default: false
      end

      define_class_options

      no_commands do
        include OperatingSystemDetectable
        include OutputHelpers
        include Interruptible
        include Reversible
        include Runnable

        def config_file_exists?(name:)
          current_config_file = config_file(name:)
          if Dir.exist?(current_config_file)
            raise StandardError, <<~ERROR_MSG
              #{current_config_file} is a directory - it should be a file. \
              This can result if you attempted to start your app (dockerized) services \
              before the app has had the chance to process the templates \
              and setup your configuration files. The root cause is docker compose \
              attempting to mount a file that doesn't exist (which creates a folder \
              by default). Delete the directory and re-try the command.
            ERROR_MSG
          end

          File.exist?(current_config_file)
        end

        protected

        def config_file_from(template:)
          File.basename(template, File.extname(template))
        end

        def config_file(name:)
          Rails.root.join('config', name).to_s
        end

        def things(count, name: 'item')
          name.pluralize(count)
        end

        def tally(collection, name)
          return unless is_enumerable?(collection)

          count = collection.count
          "#{count} #{things(count, name:)}"
        end

        def range(collection)
          return unless is_enumerable?(collection)
          return unless collection.any?

          count = collection.count
          return '[1]' if count == 1

          "[1-#{count}]"
        end

        def is_enumerable?(collection)
          collection.class.ancestors.include?(Enumerable)
        end

        # def verbose?
        #   options[:verbose]
        # end
        #
        # def dry_run?
        #   options[:dry_run]
        # end
      end
    end
  end
end

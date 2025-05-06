# frozen_string_literal: true

# See https://stackoverflow.com/a/837593/3726759
app_path = File.join(Dir.pwd, 'app')
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'thor'
require 'thor/shell/color'
require 'awesome_print'
require 'concerns/operating_system_detectable'
require 'lib/lar_city/cli/colors'

# Conventions for command or task implementation classes:
# - Use the namespace method to define a namespace for the Thor class.
# - Use the desc method to define a description for the command.
# - Use the method_option method to define options for the command.
# - Use the say method to output text to the console.
# - All text verbose output should be in Thor::Shell::Color::MAGENTA.
module LarCity
  module CLI
    class BaseCmd < Thor
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

      def self.exit_on_failure?
        true
      end

      no_commands do
        include OperatingSystemDetectable

        def run(*args, inline: false)
          with_interruption_rescue do
            cmd = args.compact.join(' ')
            if verbose? || dry_run?
              msg = <<~CMD
                Executing#{dry_run? ? ' (dry-run)' : ''}: #{cmd}
              CMD
              say(msg, dry_run? ? :magenta : :yellow)
            end
            return if dry_run?

            # # Example: doing this with Open3
            # Open3.popen2e(cmd) do |_stdin, stdout_stderr, wait_thread|
            #   Thread.new do
            #     stdout_stderr.each { |line| puts line }
            #   end
            #   wait_thread.value
            # end
            result = system(cmd, out: $stdout, err: :out)
            return result if inline

            # exit 0 if result
          end
        end

        def with_interruption_rescue(&block)
          yield block
        rescue SystemExit, Interrupt => e
          say "\nTask interrupted.", :red
          exit(1) unless verbose?
          raise e
        rescue StandardError => e
          say "An error occurred: #{e.message}", :red
          exit(1) unless verbose?
          raise e
        end

        protected

        def say_info(message)
          say(message, :cyan)
        end

        def say_warning(message)
          say(message, :yellow)
        end

        def say_success(message)
          say(message, :green)
        end

        def say_highlight(message)
          say(message, :magenta)
        end

        def say_error(message)
          say(message, :red)
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

        def verbose?
          options[:verbose]
        end

        def dry_run?
          options[:dry_run]
        end
      end
    end
  end
end

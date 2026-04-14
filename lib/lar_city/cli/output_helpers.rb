# frozen_string_literal: true

require_relative 'utils/class_helpers'

module LarCity
  module CLI
    module OutputHelpers
      extend Utils::ClassHelpers

      # @deprecated Use ClassMethods#define_output_options instead
      def self.define_class_options(thor_class)
        thor_class.class_option :help,
                                type: :boolean,
                                default: false
        thor_class.class_option :dry_run,
                                type: :boolean,
                                aliases: %w[-d --pretend --preview],
                                desc: 'Dry run',
                                default: false
        thor_class.class_option :verbose,
                                type: :boolean,
                                aliases: %w[-v --debug],
                                desc: 'Verbose output',
                                default: false
      end

      def self.included(base)
        require_thor_options_support!(base)
        # Make class methods available in base context
        base.extend ClassMethods
        # Check if thor option exists in base context
        base.include SayHelperMethods
        base.include FormatHelperMethods
      end

      module ClassMethods
        def define_output_options(thor_class = self, class_options: true)
          option_method = class_options ? :class_option : :option
          thor_class.public_send option_method, :help, type: :boolean, default: false
          # Define pretend option
          thor_class
            .public_send(
              option_method, :dry_run,
              type: :boolean,
              aliases: %w[-d --pretend --preview],
              desc: 'Dry run',
              default: false
            )
          # Define verbose option
          thor_class
            .public_send(
              option_method, :verbose,
              type: :boolean,
              aliases: %w[-v --debug],
              desc: 'Verbose output',
              default: false
            )
        end
      end

      module SayHelperMethods
        protected

        def print_line_break(span: 50)
          say('=' * span)
        end

        # Shows a calculated number of visible characters (i.e. visible_length)
        # at both the start and end.
        def partially_masked_secret(secret, visible_length: nil)
          return '' if secret.nil? || secret.empty?

          visible_length ||= [1, ([secret.length, 12].min / 4).ceil].max
          calc_masked_length = secret.length - (visible_length * 2)
          masked_length = [12, calc_masked_length].min
          if masked_length.positive?
            "#{secret[0, visible_length]}#{'*' * masked_length}#{secret[-visible_length, visible_length]}"
          else
            secret
          end
        end

        def say_debug(message)
          say_highlight(message) if verbose?
        end

        def say_info(message)
          say(message, :cyan)
        end

        def say_warning(message)
          say("⚠️ WARNING: #{message}", :yellow)
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

        def help?
          options[:help]
        end

        def verbose?
          options[:verbose]
        end

        def dry_run?
          options[:dry_run]
        end

        alias pretend? dry_run?
        alias debug? verbose?
      end

      # Provides helper methods for formatting command output, handling collections,
      # and parsing timestamps. Includes logic to make strings human-readable.
      module FormatHelperMethods
        # Extracts a timestamp from a given filename based on a specific regex pattern.
        #
        # @param filename [String] the filename to parse
        # @return [Time, nil] the parsed timestamp, or nil if no match or empty filename
        def extract_timestamp(filename)
          return nil if filename.blank?
          return unless filename =~ %r{\(?(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})(\d{2})([+-]\d{4})\)?}

          year = ::Regexp.last_match(1)
          month = ::Regexp.last_match(2)
          day = ::Regexp.last_match(3)
          hour = ::Regexp.last_match(4)
          min = ::Regexp.last_match(5)
          sec = ::Regexp.last_match(6)
          tz = ::Regexp.last_match(7)
          Time.new(year.to_i, month.to_i, day.to_i, hour.to_i, min.to_i, sec.to_i, tz)
        end

        # Show a human-readable tally of items in the collection
        def tally(collection, name)
          return unless enumerable?(collection)

          count = collection.count
          "#{count} #{things(count, name:)}"
        end

        # Show a range based on the number of items in the collection
        def range(collection)
          return unless enumerable?(collection)
          return unless collection.any?

          count = collection.count
          return '[1]' if count == 1

          "[1-#{count}]"
        end

        protected

        # Pluralizes a word based on count.
        #
        # @param count [Integer] the number of items
        # @param name [String] the word to pluralize
        # @return [String] the appropriately pluralized word
        def things(count, name: 'item')
          name.pluralize(count)
        end

        # Checks if an object is an Enumerable.
        #
        # @param collection [Object] the object to check
        # @return [Boolean] true if the collection is enumerable, false otherwise
        def enumerable?(collection)
          collection.is_a?(Enumerable)
        end
      end
    end
  end
end

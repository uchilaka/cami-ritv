# frozen_string_literal: true

require_relative 'utils/class_validators'

module LarCity
  module CLI
    module OutputHelpers
      extend Utils::ClassValidators

      def self.included(base)
        # Throw an error unless included in a Thor class

        missing_ancestor_msg = <<~MSG
          #{base.name} is not a descendant of Thor or Thor::Group.
          #{name} can only be included in Thor or Thor::Group descendants.
        MSG
        raise missing_ancestor_msg unless has_thor_ancestor?(base)

        missing_options_method_msg = <<~MSG
          #{base.name} does not support options.
          #{name} can only be included in Thor classes that support options.
        MSG
        raise missing_options_method_msg unless supports_options?(base)

        # Check if thor option exists in base context
        base.include SayHelperMethods
      end

      module SayHelperMethods
        protected

        def print_line_break(span: 50)
          say('=' * span)
        end

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

        def verbose?
          options[:verbose]
        end

        def dry_run?
          options[:dry_run]
        end

        alias pretend dry_run?
      end
    end
  end
end

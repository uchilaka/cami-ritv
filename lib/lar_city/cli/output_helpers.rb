# frozen_string_literal: true

require_relative 'utils/class_validators'

module LarCity
  module CLI
    module OutputHelpers
      extend Utils::ClassValidators

      def self.included(base)
        # Throw an error unless included in a Thor class
        raise "#{name} can only be included in Thor or Thor::Group descendants" unless has_thor_ancestor?(base)

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
      end
    end
  end
end

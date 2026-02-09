# frozen_string_literal: true

module LarCity
  module CLI
    module Utils
      module ClassHelpers
        protected

        # Throw an error unless included in a Thor class that supports options
        def require_thor_options_support!(base)
          require_thor_ancestor!(base)

          missing_options_method_msg = <<~MSG
            #{base.name} does not support options.
            #{name} can only be included in Thor classes that support options.
          MSG
          raise missing_options_method_msg unless supports_options?(base)
        end

        # Throw an error unless included in a Thor class
        def require_thor_ancestor!(base)
          missing_ancestor_msg = <<~MSG
            #{base.name} is not a descendant of Thor or Thor::Group.
            #{name} can only be included in Thor or Thor::Group descendants.
          MSG
          raise missing_ancestor_msg unless has_thor_ancestor?(base)
        end

        def has_thor_ancestor?(base)
          base.ancestors.include?(Thor) || base.ancestors.include?(Thor::Group)
        end

        def supports_options?(base)
          base.methods.include?(:options) || base.methods.include?(:class_options)
        end

        def implements_verbose?(base)
          base <= LarCity::CLI::BaseCmd || base.protected_methods.include?(:verbose?)
        end

        def implements_pretend?(base)
          base <= LarCity::CLI::BaseCmd ||
            base.protected_methods.include?(:dry_run?) ||
            base.protected_methods.include?(:pretend?)
        end
      end
    end
  end
end

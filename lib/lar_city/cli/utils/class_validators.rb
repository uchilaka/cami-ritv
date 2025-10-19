# frozen_string_literal: true

module LarCity
  module CLI
    module Utils
      module ClassValidators
        protected

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

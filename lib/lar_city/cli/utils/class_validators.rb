# frozen_string_literal: true

module LarCity
  module CLI
    module Utils
      module ClassValidators
        protected

        def has_thor_ancestor?(base)
          base.ancestors.include?(Thor) || base.ancestors.include?(Thor::Group)
        end
      end
    end
  end
end

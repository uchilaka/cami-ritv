# frozen_string_literal: true

module LarCity
  module CLI
    module Reversible
      extend ActiveSupport::Concern
      extend Utils::ClassValidators

      def self.included(base)
        # Throw an error unless included in a Thor class
        raise "#{name} can only be included in Thor or Thor::Group descendants" unless has_thor_ancestor?(base)

        base.include OutputHelpers
        base.include Interruptible

        # Make InstanceMethods available to the base context
        base.include InstanceMethods
      end

      module InstanceMethods
        def with_optional_pretend_safety(&block)
          with_interruption_rescue do
            if dry_run?
              say_warning 'Dry-run mode enabled - no changes will be made.'
              say_warning <<-TIP
                To execute the operation with persisted changes, re-run
                without the --dry-run flag.
              TIP
            end

            ActiveRecord::Base.transaction do
              result = yield block
              if dry_run?
                say_warning 'Dry-run mode enabled - triggering rollback.'
                raise ActiveRecord::Rollback
              else
                result
              end
            end
          end
        end
      end
    end
  end
end

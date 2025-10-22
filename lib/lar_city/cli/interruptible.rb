# frozen_string_literal: true

module LarCity
  module CLI
    module Interruptible
      def self.included(base)
        base.include OutputHelpers

        # Make InstanceMethods available to the base context
        base.include InstanceMethods
      end

      module InstanceMethods
        protected

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
      end
    end
  end
end

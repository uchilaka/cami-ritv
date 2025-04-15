# frozen_string_literal: true

module InteractorErrorHandling
  extend ActiveSupport::Concern

  included do
    raise "#{name} requires Interactor" unless include?(Interactor)

    before do
      context.errors = []
      context.metadata = {}
    end

    around do |interactor|
      interactor.call
    ensure
      if context.errors.any?
        Rails.logger.error(
          "#{self.class}.call failed",
          context: context.metadata,
          errors: context.errors
        )
      end
    end
  end
end

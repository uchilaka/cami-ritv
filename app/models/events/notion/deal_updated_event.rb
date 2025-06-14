# frozen_string_literal: true

module Notion
  class DealUpdatedEvent < ::GenericEvent
    include AASM

    aasm column: :status do
      state :pending, initial: true
      state :processing
      state :completed
      state :failed

      event :process do
        transitions from: :pending, to: :processing
      end

      event :complete do
        transitions from: :processing, to: :completed
      end

      event :fail do
        transitions from: %i[pending processing], to: :failed
      end
    end

    # See SO recommendation: https://stackoverflow.com/a/9463495/3726759
    def self.model_name
      GenericEvent.model_name
    end
  end
end

# frozen_string_literal: true

module Notion
  class DealUpdatedEvent < ::GenericEvent
    include AASM

    # TODO: Require this after implementing the workflow for
    #   capturing Notion deal CRUD events which should include
    #   entity_id, integration_id, database_id, type and other
    #   relevant fields to inform an async job to create a deal
    #   in the system.
    belongs_to :metadatum, optional: true, dependent: :destroy

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

# frozen_string_literal: true

module Notion
  class BaseEvent < ::GenericEvent
    include AASM

    # TODO: Require this after implementing the workflow for
    #   capturing Notion deal CRUD events which should include
    #   entity_id, integration_id, database_id, type and other
    #   relevant fields to inform an async job to create a deal
    #   in the system.
    has_one :metadatum, lambda {
      where(appendable_type: 'Notion::WebhookEventMetadatum')
    }, inverse_of: :appendable, dependent: :destroy

    accepts_nested_attributes_for :metadatum

    delegate :entity_id, :integration_id, :database_id, to: :metadatum

    alias remote_record_id entity_id

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
  end
end

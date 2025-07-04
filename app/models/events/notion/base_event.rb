# frozen_string_literal: true

# == Schema Information
#
# Table name: generic_events
#
#  id             :uuid             not null, primary key
#  eventable_type :string
#  slug           :string
#  status         :string
#  type           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  eventable_id   :uuid
#
# Indexes
#
#  index_generic_events_on_eventable  (eventable_type,eventable_id)
#  index_generic_events_on_slug       (slug) UNIQUE
#
module Notion
  class BaseEvent < ::GenericEvent
    include AASM

    delegate :variant,
             :entity_id,
             :integration_id,
             :database_id,
             :workspace_id,
             :workspace_name,
             :attempt_number,
             :database,
             :entity, to: :metadatum

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

    def variant
      return nil if metadatum.blank?

      metadatum.key.split('.').last
    end
  end
end

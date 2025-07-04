# frozen_string_literal: true

# == Schema Information
#
# Table name: generic_events
#
#  id             :uuid             not null, primary key
#  eventable_type :string
#  status         :string
#  type           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  eventable_id   :uuid
#
# Indexes
#
#  index_generic_events_on_eventable  (eventable_type,eventable_id)
#
module Notion
  class DealCreatedEvent < BaseEvent
    # See SO recommendation: https://stackoverflow.com/a/9463495/3726759
    def self.model_name
      GenericEvent.model_name
    end

    # TODO: Add testing for these delegated attributes to ensure that when they
    #   are not set, validations are triggered with useful error messages.
    validates :entity_id, presence: true, if: -> { metadatum&.entity_id.blank? }
    validates :integration_id, presence: true, if: -> { metadatum&.integration_id.blank? }
    validates :database_id, presence: true, if: -> { metadatum&.database_id.blank? }
    validates :workspace_id, presence: true, if: -> { metadatum&.workspace_id.blank? }
    validates :workspace_name, presence: true, if: -> { metadatum&.workspace_name.blank? }
    validates :remote_record_id, presence: true, if: -> { metadatum&.remote_record_id.blank? }
    validates :attempt_number,
              numericality: { only_integer: true, greater_than_or_equal_to: 1 },
              if: -> { metadatum&.attempt_number.blank? }
  end
end

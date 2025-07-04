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
    # validates :entity_id, :database_id, :workspace_id, :workspace_name, presence: true
  end
end

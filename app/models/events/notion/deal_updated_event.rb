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
  # TODO: Implement after_commit to enqueue job to process the deal update as a side effect of upserting the event
  class DealUpdatedEvent < BaseEvent
    # See SO recommendation: https://stackoverflow.com/a/9463495/3726759
    def self.model_name
      GenericEvent.model_name
    end

    validates_with DealEventValidator
  end
end

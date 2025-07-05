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
  class DealCreatedEventSerializer < ActiveModel::Serializer
    attributes :id, :slug, :workspace_id, :workspace_name,
               :subscription_id, :integration_id, :remote_record_id,
               :entity_id, :database_id, :created_at, :updated_at,
               :type, :entity, :database

    def entity_id
      from_metadata('entity', 'id')
    end

    def database_id
      from_metadata('database', 'id')
    end

    def workspace_id
      from_metadata('workspace_id')
    end

    def workspace_name
      from_metadata('workspace_name')
    end

    def subscription_id
      from_metadata('subscription_id')
    end

    private

    def from_metadata(*attribute_names)
      object.metadatum.value.dig(*attribute_names)
    end
  end
end

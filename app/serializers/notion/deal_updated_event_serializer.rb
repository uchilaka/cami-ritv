# frozen_string_literal: true

module Notion
  class DealUpdatedEventSerializer < ActiveModel::Serializer
    attributes :id, :workspace_id, :workspace_name,
               :subscription_id, :integration_id, :remote_record_id,
               :entity_id, :database_id, :created_at, :updated_at,
               :type, :entity, :database

    def remote_record_id
      from_value('remote_record_id')
    end

    def entity_id
      from_value('entity', 'id')
    end

    def database_id
      from_value('database', 'id')
    end

    def subscription_id
      from_value('subscription_id')
    end

    def integration_id
      from_value('integration_id')
    end

    def workspace_id
      from_value('workspace_id')
    end

    def workspace_name
      from_value('workspace_name')
    end

    private

    def from_value(*attribute_names)
      object.metadatum.value.dig(**attribute_names)
    end
  end
end

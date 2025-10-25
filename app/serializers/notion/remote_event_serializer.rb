# frozen_string_literal: true

module Notion
  class RemoteEventSerializer < ActiveModel::Serializer
    attributes :id, :workspace_id, :workspace_name, :timestamp,
               :subscription_id, :integration_id, :attempt_number,
               :type, :parent, :entity, :database

    def database
      object.parent if object.parent&.type == 'database'
    end
  end
end

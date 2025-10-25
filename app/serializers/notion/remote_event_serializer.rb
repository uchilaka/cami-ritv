# frozen_string_literal: true

module Notion
  class RemoteEventSerializer < ActiveModel::Serializer
    attributes :id, :type, :workspace_id, :workspace_name, :timestamp,
               :subscription_id, :integration_id, :attempt_number,
               :parent, :entity, :authors, :database

    def database
      object.parent if object.parent&.type == 'database'
    end
  end
end

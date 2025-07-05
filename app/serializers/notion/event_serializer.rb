# frozen_string_literal: true

module Notion
  class EventSerializer < ActiveModel::Serializer
    attributes :id, :timestamp, :workspace_id, :workspace_name,
               :subscription_id, :integration_id, :attempt_number,
               :type, :entity, :parent, :authors
  end
end

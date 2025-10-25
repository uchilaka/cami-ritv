# frozen_string_literal: true

module Notion
  class EventSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    delegate :hostname, to: AppUtils

    # TODO: Check if attempt_number is inherited and works for Notion::DealCreatedEventSerializer
    attributes :id, :slug, :status, :workspace_id, :workspace_name, :timestamp,
               :subscription_id, :integration_id, :remote_record_id, :attempt_number,
               :entity_id, :database_id, :created_at, :updated_at,
               :type, :entity, :database, :url

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

    # def parent
    #   from_metadata('parent')
    # end
    #
    # def authors
    #   from_metadata('authors')
    # end

    def subscription_id
      from_metadata('subscription_id')
    end

    def timestamp
      from_metadata('event', 'timestamp')
    end

    def url
      webhook_event_url(object.eventable, object, host: hostname, format: :json)
    end

    protected

    def from_metadata(*attribute_names)
      object.metadatum.value.dig(*attribute_names)
    end
  end
end

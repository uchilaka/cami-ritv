# frozen_string_literal: true

module Notion
  class DealEventSerializer < BaseEventSerializer
    # include Rails.application.routes.url_helpers
    #
    # delegate :hostname, to: AppUtils

    attributes :id, :slug, :status, :workspace_id, :workspace_name,
               :subscription_id, :integration_id, :remote_record_id,
               :entity_id, :database_id, :created_at, :updated_at,
               :type, :entity, :database, :url, :deal_url, :download_deal_url

    # def entity_id
    #   from_metadata('entity', 'id')
    # end
    #
    # def database_id
    #   from_metadata('database', 'id')
    # end
    #
    # def workspace_id
    #   from_metadata('workspace_id')
    # end
    #
    # def workspace_name
    #   from_metadata('workspace_name')
    # end
    #
    # def subscription_id
    #   from_metadata('subscription_id')
    # end
    #
    # def url
    #   webhook_event_url(object.eventable, object, host: hostname, format: :json)
    # end

    def deal_url
      webhook_record_url(object.eventable, object, host: hostname)
    end

    def download_deal_url
      api_v2_webhooks_notion_event_deal_url(object, host: hostname, format: :json)
    end

    # def timestamp
    #   from_metadata('entity', 'timestamp')
    # end
    #
    # private
    #
    # def from_metadata(*attribute_names)
    #   object.metadatum.value.dig(*attribute_names)
    # end
  end
end

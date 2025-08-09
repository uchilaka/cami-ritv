# frozen_string_literal: true

module Notion
  class FetchDealJob < ApplicationJob
    def perform(remote_record_id:, webhook_slug:, source_event_id: nil)
      webhook = Webhook.friendly.find(webhook_slug)
      source_event = GenericEvent.find(source_event_id) if source_event_id.present?
      Notion::DownloadDealWorkflow.call(remote_record_id:, webhook:, source_event:)
    end

    private

    def client
      @client ||= Notion::Client.new
    end
  end
end

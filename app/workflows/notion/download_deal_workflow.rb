# frozen_string_literal: true

module Notion
  class DownloadDealWorkflow
    include Interactor
    include DealProcessable

    delegate :webhook, :source_event, :remote_record_id,
             :record_data, :result, to: :context

    # Each record of the Deal Pipeline database is a page in Notion.
    alias page_id remote_record_id

    def call
      fetch_remote_record
      process_result
    rescue StandardError => e
      context.fail!(error: e, message: "Failed to download deal from Notion: #{e.message}")
    end

    private

    def process_result
      return context.fail!(message: 'No results returned from Notion') if context.record_data.blank?

      context.record = process_deal(record_data)
    end

    def fetch_remote_record
      client = Notion::Client.new
      context.record_data = client.get_entity(id: page_id, type: 'page')
    end
  end
end

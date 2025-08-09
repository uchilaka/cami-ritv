# frozen_string_literal: true

module Notion
  class DownloadDealWorkflow
    include Interactor

    delegate :webhook, :source_event, :remote_record_id,
             :response_hash, :result, to: :context

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
      return context.fail!(message: 'No results returned from Notion') if context.response_hash['results'].empty?

      adapter = Notion::DealQueryResultAdapter.new(context.response_hash['results'])
      context.records = adapter.process_deals
    end

    def fetch_remote_record
      client = Notion::Client.new
      context.response_hash = client.get_entity(id: page_id, type: 'page')
    end
  end
end

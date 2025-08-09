# frozen_string_literal: true

module Notion
  class DownloadDealWorkflow
    include Interactor

    delegate :webhook, :database_id, :source_event,
             :response_hash, :result, to: :context
    delegate :remote_record_id, to: :source_event

    def call
      fetch_remote_record
      process_result
    rescue StandardError => e
      context.fail!(error: e, message: "Failed to download deal from Notion: #{e.message}")
    end

    private

    def process_result
    end

    def fetch_remote_record
      client = Notion::Client.new
      # Fetch from the deals database - this should have been provisioned in the devkit
      #   command when setting up the Notion (webhook) integration.
      context.database_id = webhook.data['deal_database_id']
    end
  end
end

# frozen_string_literal: true

module Notion
  class DownloadDealWorkflow
    include Interactor

    delegate :webhook, :database_id, :remote_record_id,
             :response_hash, :result, to: :context

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
    end
  end
end

# frozen_string_literal: true

module Notion
  module Deals
    class DownloadWorkflow
      include Interactor
      include DealProcessable

      delegate :webhook, :source_event, :remote_record_id,
               :record_data, :success?, to: :context

      # Each record of the Deal Pipeline database is a page in Notion.
      alias page_id remote_record_id

      def call
        fetch_remote_record
        return unless success?

        process_result
      rescue StandardError => e
        Rails.logger.error(e.message || 'Failed to download deal from Notion', error: e)
        context.fail!(message: e.message, error: e)
      end

      private

      def process_result
        raise 'No data returned from Notion' unless record_data.present?

        @deal = process_deal(record_data)
        context.record = @deal
      end

      def fetch_remote_record
        client = Notion::Client.new
        context.record_data = client.get_entity(id: page_id, type: 'page')
      end
    end
  end
end

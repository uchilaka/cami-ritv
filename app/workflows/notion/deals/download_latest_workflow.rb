# frozen_string_literal: true

module Notion
  module Deals
    # TODO: TDD for this workflow to be used to download the latest deals from Notion.
    #   It isn't yet tested - assume nothing works correctly 😅.
    class DownloadLatestWorkflow
      include Interactor

      # TODO: Is context.results being used?
      delegate :webhook, :database_id,
               :interval, :query_params, :filters,
               :response_hash, :success?, :results, to: :context

      INTERVALS = {
        six_months: 6.months,
        three_months: 3.months,
        one_month: 1.month,
        one_week: 1.week,
      }.freeze

      SUPPORTED_FILTERS = %i[skip_lost_deals skip_won_deals deal_stage start_date end_date].freeze

      def call
        context.filters ||= { skip_lost_deals: false, skip_won_deals: false }
        supported_filters = filters.slice(*SUPPORTED_FILTERS)
        Rails.logger.info("#{self.class}.call", supported_filters:)
        unsupported_filters = filters.keys - SUPPORTED_FILTERS
        Rails.logger.warn("#{self.class}.call", unsupported_filters:) if unsupported_filters.any?
        context.start_date ||= (INTERVALS[context.interval] || INTERVALS[:three_months]).ago.beginning_of_day
        context.end_date ||= Time.current.end_of_day

        context.query_params = build_query_params

        fetch_remote_records
        return unless success?

        process_results
      rescue StandardError => e
        context.fail!(error: e, message: "Failed to download deals from Notion: #{e.message}")
      end

      private

      def has_filter?(filter_key)
        filters.key?(filter_key) && filters[filter_key].present?
      end

      def filter(filter_key)
        context.filters ||= {}
        filters[filter_key.to_sym]
      end

      def build_query_params
        # Notion API database query filtering: https://developers.notion.com/reference/post-database-query-filter
        predicates = [
          has_filter?(:start_date) && {
            timestamp: 'created_time',
            created_time: {
              on_or_after: filter(:start_date).iso8601,
            },
          },
          has_filter?(:end_date) && {
            timestamp: 'created_time',
            created_time: {
              on_or_before: filter(:end_date).iso8601,
            },
          },
          has_filter?(:deal_stage) && {
            property: 'Deal stage',
            select: {
              equals: filter(:deal_stage),
            },
          },
          filter(:skip_won_deals) && {
            property: 'Deal stage',
            select: {
              does_not_equal: 'Won',
            },
          },
          filter(:skip_lost_deals) && {
            property: 'Deal stage',
            select: {
              does_not_equal: 'Lost',
            },
          },
        ].select(&:itself)

        # Return query hash with filters and sorts
        query_hash = {
          sorts: [
            {
              timestamp: 'created_time',
              direction: 'descending',
            },
          ],
          page_size: 100,
        }
        return query_hash if predicates.blank?

        query_hash[:filter] ||= {}
        query_hash[:filter][:and] = predicates
        query_hash
      end

      def fetch_remote_records
        client = Notion::Client.new

        # Fetch from the deals database - this should have been provisioned in the devkit
        #   command when setting up the Notion (webhook) integration.
        context.database_id = webhook.data['deal_database_id']

        # Notion API database query: https://developers.notion.com/reference/post-database-query
        context.response_hash = client.database_query(database_id:, query_params: context.query_params)

        # Handle pagination if needed
        handle_pagination(client, database_id) if response_hash['has_more']
      end

      def handle_pagination(client, database_id)
        all_results = response_hash['results']
        next_cursor = response_hash['next_cursor']

        while next_cursor
          next_page_params = context.query_params.merge(start_cursor: next_cursor)

          response = client.database_query(
            database_id: database_id,
            query_params: next_page_params
          )

          all_results.concat(response['results'])
          next_cursor = response['has_more'] ? response['next_cursor'] : nil
        end

        context.response_hash['results'] = all_results
        context.response_hash['has_more'] = false
        context.response_hash['next_cursor'] = nil
      end

      def process_results
        return context.fail!(message: 'No results returned from Notion') if context.response_hash['results'].empty?

        adapter = Notion::DealQueryResultAdapter.new(context.response_hash['results'])
        context.records = adapter.process_deals
      end
    end
  end
end

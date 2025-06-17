# frozen_string_literal: true

module Notion
  # TODO: TDD for this workflow to be used to download the latest deals from Notion.
  #   It isn't yet tested - assume nothing works correctly 😅.
  class DownloadLatestDealsWorkflow
    include Interactor

    delegate :results, to: :context

    SIX_MONTH_INTERVAL = 6.months

    def call
      context.start_date ||= SIX_MONTH_INTERVAL.ago.beginning_of_day
      context.end_date ||= Time.current.end_of_day

      context.query_params = build_query_params

      fetch_deals_from_notion
      process_results
    rescue StandardError => e
      context.fail!(error: e, message: "Failed to download deals from Notion: #{e.message}")
    end

    private

    def build_query_params
      {
        filter: {
          and: [
            {
              property: 'created_time',
              date: {
                on_or_after: context.start_date.iso8601,
              },
            },
            {
              property: 'created_time',
              date: {
                on_or_before: context.end_date.iso8601,
              },
            }
          ],
        },
        sorts: [
          {
            property: 'created_time',
            direction: 'descending',
          }
        ],
        page_size: 100,
      }
    end

    def fetch_deals_from_notion
      client = Notion::Client.new

      # Fetch from the deals database - assuming the database_id is in configuration
      database_id = Rails.application.config.notion.deals_database_id

      context.raw_results = client.database_query(
        database_id: database_id,
        query_params: context.query_params
      )

      # Handle pagination if needed
      handle_pagination(client, database_id) if context.raw_results['has_more']
    end

    def handle_pagination(client, database_id)
      all_results = context.raw_results['results']
      next_cursor = context.raw_results['next_cursor']

      while next_cursor
        next_page_params = context.query_params.merge(start_cursor: next_cursor)

        response = client.database_query(
          database_id: database_id,
          query_params: next_page_params
        )

        all_results.concat(response['results'])
        next_cursor = response['has_more'] ? response['next_cursor'] : nil
      end

      context.raw_results['results'] = all_results
      context.raw_results['has_more'] = false
      context.raw_results['next_cursor'] = nil
    end

    def process_results
      return context.fail!(message: 'No results returned from Notion') if context.raw_results['results'].empty?

      adapter = Notion::DealQueryResultAdapter.new(context.raw_results)
      context.results = adapter.process_deals
    end
  end
end

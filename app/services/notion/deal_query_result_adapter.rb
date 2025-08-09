# frozen_string_literal: true

module Notion
  # app/services/notion_adapter.rb
  class DealQueryResultAdapter
    include DealProcessable

    # The NotionAdapter is responsible for processing the data from the Notion API.
    # It is initialized with the results from the Notion API and then the process_deals
    # method is called to process the data.
    def initialize(results)
      @results = results
    end

    # The process_deals method will iterate over the results and create a Deal object
    # for each result.
    def process_deals
      @results.map { |deal_data| process_deal(deal_data) }
    end
  end
end

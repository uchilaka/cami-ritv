# frozen_string_literal: true

module Notion
  module API
    class Error < StandardError
      attr_reader :status, :body

      def initialize(message, status: nil, body: nil)
        super(message)
        @status = status
        @body = body
      end
    end
  end

  class Client
    BASE_URL = 'https://api.notion.com/v1'
    API_VERSION = '2022-06-28'

    attr_reader :http_client

    def initialize
      @http_client = LarCity::HttpClient.client do |client|
        client.headers['Authorization'] = "Bearer #{api_token}"
        client.headers['Notion-Version'] = ENV.fetch('NOTION_API_VERSION', API_VERSION)
        client.headers['Content-Type'] = 'application/json'
      end
    end

    # Query a Notion database with provided filters and parameters
    # @param database_id [String] The ID of the Notion database to query
    # @param query_params [Hash] The query parameters to send to the Notion API
    # @return [Hash] The parsed JSON response from the Notion API
    def database_query(database_id:, query_params:)
      response = http_client.post(
        "#{BASE_URL}/databases/#{database_id}/query",
        query_params
      )

      handle_response(response)
    end

    private

    def api_token
      ENV.fetch('NOTION_API_TOKEN', Rails.application.credentials.notion.secret_key)
    end

    def handle_response(response)
      if response.success?
        JSON.parse(response.body)
      else
        error_message = extract_error_message(response)
        raise API::Error.new(
          "Notion API Error: #{error_message}",
          status: response.status,
          body: response.body
        )
      end
    end

    def extract_error_message(response)
      parsed_body = JSON.parse(response.body)
      parsed_body.dig('error', 'message') || "Unknown error (status #{response.status})"
    rescue JSON::ParserError
      "Invalid JSON response (status #{response.status}): #{response.body}"
    end
  end
end

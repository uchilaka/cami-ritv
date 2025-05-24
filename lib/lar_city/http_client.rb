# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'faraday/middleware'

module LarCity
  # Provides a configured Faraday HTTP client with retry logic and JSON parsing.
  #
  # @example Basic usage
  #   client = LarCity::HttpClient.client
  #   response = client.get('https://api.example.com/endpoint')
  #   data = response.body
  #
  # @example With custom headers
  #   client = LarCity::HttpClient.client
  #   client.headers['Authorization'] = 'Bearer token'
  #   response = client.get('https://api.example.com/secure')
  class HttpClient
    class << self
      # Returns a configured Faraday client instance.
      #
      # @return [Faraday::Connection] A configured Faraday client
      def client
        @client ||= new_client
      end

      # Creates a new Faraday client with default configuration.
      #
      # @return [Faraday::Connection] A new Faraday client instance
      def new_client
        Faraday.new do |conn|
          # Request middleware runs before the request is made
          conn.request :retry, retry_options
          conn.request :json
          
          # Response middleware parses the response
          conn.response :json, content_type: /\bjson$/
          conn.response :raise_error
          
          # Use the default adapter (Net::HTTP)
          conn.adapter Faraday.default_adapter
          
          # Set default headers
          conn.headers['User-Agent'] = "LarCity/#{LarCity::VERSION} (Ruby #{RUBY_VERSION})"
          conn.headers['Accept'] = 'application/json'
        end
      end
      
      private
      
      # Default retry options for HTTP requests
      # @return [Hash] Retry configuration
      def retry_options
        {
          max: 3,
          interval: 0.5,
          interval_randomness: 0.5,
          backoff_factor: 2,
          exceptions: [
            Faraday::TimeoutError,
            Faraday::ConnectionFailed,
            Faraday::BadRequestError,
            Faraday::ServerError,
            Faraday::ParsingError,
            Faraday::ConnectionFailed,
            Faraday::TimeoutError,
            Errno::ETIMEDOUT,
            Net::OpenTimeout,
            SocketError
          ]
        }
      end
    end
  end
end

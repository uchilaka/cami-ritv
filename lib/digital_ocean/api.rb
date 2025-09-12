# frozen_string_literal: true

require 'lib/lar_city/http_client'

module DigitalOcean
  class API
    class << self
      def http_client(access_token: nil)
        if access_token.blank?
          @http_client ||= new_http_client
        else
          @http_client = new_http_client(access_token:)
        end
      end

      def delete_domain_record(id)
        http_client.delete(v2_endpoint("domains/#{domain}/records/#{id}"))
      end

      def v2_endpoint(uri = '')
        "https://api.digitalocean.com/v2/#{uri}"
      end

      private

      def new_http_client(access_token: nil)
        selected_access_token = access_token || default_access_token
        raise 'DigitalOcean access token is not set' if selected_access_token.blank?

        new_client = ::LarCity::HttpClient.new_client
        new_client.headers['Authorization'] = "Bearer #{selected_access_token}"
        new_client
      end

      def default_access_token
        ENV.fetch('DIGITALOCEAN_ACCESS_TOKEN', Rails.application.credentials.digitalocean&.access_token)
      end
    end
  end
end

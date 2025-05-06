# frozen_string_literal: true

module PayPal
  class AbstractJob < ApplicationJob
    queue_as :yeet

    def connection
      @connection ||= Faraday.new(
        url: vendor_credentials.api_base_url,
        headers: {
          'Content-Type': 'application/json',
        }
      ) do |builder|
        builder.request :authorization, :basic,
                        vendor_credentials.client_id,
                        vendor_credentials.client_secret
        builder.request :json
        builder.response :json
        builder.response :logger if Rails.env.development?
        builder.response :raise_error, include_request: true
      end
    end

    def vendor_credentials
      @vendor_credentials ||=
        if (credentials = Rails.application.credentials&.paypal&.presence)
          Struct::VendorConfig.new(
            api_base_url:,
            client_id: ENV.fetch('PAYPAL_CLIENT_ID', credentials.client_id),
            client_secret: ENV.fetch('PAYPAL_CLIENT_SECRET', credentials.client_secret)
          )
        end
    end

    def api_base_url
      @api_base_url ||= ENV.fetch('PAYPAL_API_BASE_URL', Rails.application.credentials&.paypal&.api_base_url)
    end

    def vendor
      @vendor ||= Business.find_by(slug: 'paypal')
    end
  end
end

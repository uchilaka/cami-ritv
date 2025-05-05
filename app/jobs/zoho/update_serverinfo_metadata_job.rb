# frozen_string_literal: true

module Zoho
  class UpdateServerinfoMetadataJob < ApplicationJob
    queue_as :yeet

    def perform(*args)
      response =
        API::Account
          .connection(auth: true)
          .get('/oauth/serverinfo')
      data = response.body || {}

      url = data.dig('locations', 'us')
      raise ::LarCity::Errors::Unknown3rdPartyHostError unless valid_http_host?(url)

    end
  end
end

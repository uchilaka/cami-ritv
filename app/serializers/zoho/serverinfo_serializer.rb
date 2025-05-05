# frozen_string_literal: true

module Zoho
  class ServerinfoSerializer < AdhocSerializer
    def attributes
      @attributes = { key:, location:, endpoint:, region: } unless defined?(@attributes)
      @attributes.compact
    end

    def key
      object.key
    end

    def region
      object.region_alpha2.to_s.upcase
    end

    alias location region
    alias region_iso3166 region

    def endpoint
      object.endpoint || 'https://accounts.zoho.com'
    end
  end
end

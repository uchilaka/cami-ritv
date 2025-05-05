# frozen_string_literal: true

module Zoho
  class Serverinfo < Metadatum
    store_accessor :value, :oauth

    after_initialize :lookup_region_name, if: -> { region_alpha2.present? }

    def endpoint
      value.dig('oauth', 'endpoint')
    end

    def endpoint=(value)
      self.oauth ||= {}
      self.oauth['endpoint'] = value
    end

    def region_alpha2
      value.dig('oauth', 'region_alpha2')
    end

    def region_alpha2=(value)
      self.oauth ||= {}
      self.oauth['region_alpha2'] = value.upcase
    end

    def region_name=(value)
      self.oauth ||= {}
      self.oauth['region_name'] = value
    end

    def region_name
      value.dig('oauth', 'region_name')
    end

    def lookup_region_name
      self.region_name = LarCity::GeoRegions.lookup(region_alpha2, :name)
    end
  end
end

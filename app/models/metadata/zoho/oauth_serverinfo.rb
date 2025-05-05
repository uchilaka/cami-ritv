# frozen_string_literal: true

module Zoho
  class OauthServerinfo < Metadatum
    store_accessor :value, :endpoint, :region_alpha2, :region_name

    after_initialize :lookup_region_name, if: -> { region_alpha2.present? }

    def lookup_region_name
      self.region_name = LarCity::GeoRegions.lookup(region_alpha2, :name)
    end
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata
#
#  id         :uuid             not null, primary key
#  key        :string           not null
#  type       :string           default("Metadatum"), not null
#  value      :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_for_zoho_oauth_serverinfo_metadata  (((value ->> 'region_alpha2'::text)))
#
module Zoho
  class OauthServerinfo < Metadatum
    store_accessor :value, :endpoint, :region_alpha2, :region_name, :resource_url

    after_initialize :lookup_region_name, if: -> { region_alpha2.present? }

    def lookup_region_name
      self.region_name = LarCity::GeoRegions.lookup(region_alpha2, :name)
    end
  end
end

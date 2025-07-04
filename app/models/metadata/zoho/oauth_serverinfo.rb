# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata
#
#  id              :uuid             not null, primary key
#  appendable_type :string
#  key             :string           not null
#  type            :string           default("Metadatum"), not null
#  value           :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  appendable_id   :uuid
#
# Indexes
#
#  index_for_zoho_oauth_serverinfo_metadata  (((value ->> 'region_alpha2'::text)))
#  index_metadata_on_appendable              (appendable_type,appendable_id)
#
module Zoho
  class OauthServerinfo < Metadatum
    store_accessor :value, :endpoint, :region_alpha2, :region_name, :resource_url

    scope :having_region_alpha2, lambda { |region_alpha2|
      where("value ->> 'region_alpha2' = ?", region_alpha2.strip.to_s.upcase)
    }

    after_initialize :lookup_region_name, if: -> { region_alpha2.present? }

    def lookup_region_name
      self.region_name = LarCity::GeoRegions.lookup(region_alpha2, :name)
    end
  end
end

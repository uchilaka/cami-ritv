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
  class OauthServerinfoSerializer < AdhocSerializer
    def attributes
      @attributes = { key:, location:, endpoint:, region:, resource_url: } unless defined?(@attributes)
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

    def resource_url
      object.resource_url
    end
  end
end

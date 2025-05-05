# frozen_string_literal: true

module Zoho
  class UpdateServerinfoMetadata
    include Interactor

    def call
      metadata_map =
        Zoho::API::Account
          .serverinfo
          .entries
          .each_with_object([]) do |(_region_alpha2, obj), inserts|
            key, value = obj.values_at(:key, :value)
            inserts << { key:, value: }
          end
      Zoho::OauthServerinfo.transaction do
        metadata_map.each do |obj|
          config_key = obj[:key]
          config_value = obj[:value]
          region_name, region_alpha2, endpoint = config_value.values_at :region_name, :region_alpha2, :endpoint
          record = Zoho::OauthServerinfo.find_or_initialize_by(
            key: config_key,
            value: {
              region_alpha2:,
            }
          )
          record.region_name = region_name
          record.region_alpha2 = region_alpha2
          record.endpoint = endpoint
          record.save!
        end
      end
    end
  end
end

# frozen_string_literal: true

module Zoho
  class UpdateServerinfoMetadata
    include Interactor

    def call
      input_region_alpha2 = context.region_alpha2
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
          endpoint, region_name, region_alpha2, resource_url = obj[:value].values_at :endpoint,
                                                                                     :region_name,
                                                                                     :region_alpha2,
                                                                                     :resource_url
          next if input_region_alpha2.present? && input_region_alpha2 != region_alpha2

          config_key = obj[:key]
          record = Zoho::OauthServerinfo.find_or_initialize_by(key: config_key)
          record.endpoint = endpoint.to_s
          record.region_name = region_name.to_s
          record.region_alpha2 = region_alpha2.to_s
          record.resource_url = resource_url.to_s
          record.save!
        end
      end
    end
  end
end

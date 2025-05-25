# frozen_string_literal: true

module Zoho
  module API
    class Account < Model
      # About class (instance) variables: https://www.ruby-lang.org/en/documentation/faq/8/
      @resource_url ||= nil

      class << self
        def upsert(record, pretend: false)
          access_token = AccessToken.generate['access_token']
          resource_uri = "/crm/v7/#{module_name}/upsert"
          payload = {
            data: [
              Zoho::AccountSerializer.new(record).serializable_hash,
            ],
            duplicate_check_fields: %w[Email Phone],
            trigger: ['workflow'],
          }
          if pretend
            Rails.logger.info("Pretending to upsert #{module_name} record data", payload:)
            return
          end

          response = connection(access_token:).post(resource_uri, payload)
          response.body
        end

        def serverinfo
          response = connection(auth: true).get('/oauth/serverinfo')
          data = response.body || {}

          url = data.dig('locations', 'us')
          raise ::LarCity::Errors::Unknown3rdPartyHostError unless valid_http_host?(url)

          data['locations'].each_with_object({}) do |(region_alpha2, endpoint), result|
            country = LarCity::GeoRegions.lookup(region_alpha2)
            next if country.blank? && !valid_server_region?(region_alpha2)

            region_name = country.blank? ? region_alpha2 : country[:name]
            result[region_alpha2.to_s.upcase.to_sym] = {
              key: endpoint.to_s,
              value: {
                endpoint: endpoint.to_s,
                resource_url: response.env.url.to_s,
                region_alpha2: region_alpha2.to_s.upcase,
                region_name:,
              },
            }
          end
        end

        def resource_url(auth: true)
          return auth_endpoint_url if auth

          base_url(auth:)
        end

        def base_url(auth: false, endpoint: nil)
          return 'https://accounts.zoho.com' if auth

          super
        end

        def sync_callback!(result, account:)
          info = result.dig('data', 0)
          code, action = info&.values_at('code', 'action')
          if code == ResponseCodes::SUCCESS
            remote_crm_id = info.dig('details', 'id')
            case action
            when 'insert'
              account.update!(remote_crm_id:, last_sent_to_crm_at: Time.zone.now)
            else
              Rails.logger.warn('An unsupported action occurred against a Zoho account record', result:)
            end
          else
            Rails.logger.error('Failed to upsert Zoho account record', result:)
          end
          { code:, action:, info: }
        end

        private

        def module_name
          name.to_s.split('::').last.pluralize.capitalize
        end
      end
    end
  end
end

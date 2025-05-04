# frozen_string_literal: true

module Zoho
  module API
    class Model
      class << self
        def connection(auth: false, access_token: nil)
          url = base_url(auth:)
          Faraday.new(url:) do |builder|
            builder.request :authorization, 'Zoho-oauthtoken', access_token if access_token.present?
            builder.request :json
            builder.response :json
            builder.response :logger if Rails.env.development?
            builder.response :raise_error, include_request: true
          end
        end

        def base_url(*)
          'https://www.zohoapis.com'
        end

        def auth_endpoint_url
          @auth_endpoint_url ||= regional_oauth_endpoint_url
        end

        def regional_oauth_endpoint_url(region = 'us')
          unless allowed_regions.include?(region.to_sym)
            exception = ::LarCity::Errors::Unknown3rdPartyHostError.new('Unsupported 3rd party service region')
            raise exception
          end

          response = connection(auth: true).get('/oauth/serverinfo')
          data = response.body || {}
          url = data.dig('locations', region.to_s)
          raise ::LarCity::Errors::Unknown3rdPartyHostError unless valid_http_host?(url)

          if %r{https://accounts\.zoho\.(eu|uk|com)}.match?(url)
            url
          else
            raise ::LarCity::Errors::Unknown3rdPartyHostError, 'Unexpected Zoho OAuth endpoint URL'
          end
        end

        def fields_list_url
          "https://crm.zoho.com/crm/org#{org_id}/settings/api/modules/#{module_name}?step=FieldsList"
        end

        def resource_url(args = {})
          raise NotImplementedError, "You must implement the #{name}.#{__method__} method"
        end

        protected

        def valid_http_host?(url_or_hostname)
          hostname = URI.parse(url_or_hostname).host
          allowed_hosts.include?(hostname)
        end

        private

        def allowed_regions
          @allowed_regions ||=
            AppUtils
              .allowed_hosts_for(provider: :zoho)[:by_region]
              .keys
        end

        def allowed_hosts
          @allowed_hosts ||=
            AppUtils
              .allowed_hosts_for(provider: :zoho)[:by_region]
              .entries
              .map { |_r, host| host }
        end

        def module_name
          raise NotImplementedError, "You must implement the #{name}.#{__method__} method"
        end

        def org_id
          ENV.fetch('CRM_ORG_ID', Rails.application.credentials&.zoho&.org_id)
        end
      end
    end
  end
end

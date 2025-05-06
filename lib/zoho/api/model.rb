# frozen_string_literal: true

module Zoho
  module API
    class Model
      class << self
        def connection(auth: false, access_token: nil, endpoint: nil)
          url = base_url(auth:, endpoint:)
          Faraday.new(url:) do |builder|
            builder.request :authorization, 'Zoho-oauthtoken', access_token if access_token.present?
            builder.request :json
            builder.response :json
            builder.response :logger if Rails.env.development?
            builder.response :raise_error, include_request: true
          end
        end

        def base_url(args)
          args[:endpoint] || 'https://www.zohoapis.com'
        end

        def auth_endpoint_url
          @auth_endpoint_url ||= regional_oauth_endpoint_url
        end

        def serverinfo
          raise NotImplementedError, "You MUST implement the #{name}.#{__method__} method"
        end

        def fields_list_url
          "https://crm.zoho.com/crm/org#{org_id}/settings/api/modules/#{module_name}?step=FieldsList"
        end

        def resource_url(args = {})
          raise NotImplementedError, "You must implement the #{name}.#{__method__} method"
        end

        protected

        def valid_server_region?(region)
          %w[EU UK].include?(region.to_s.strip.upcase)
        end

        def valid_http_host?(url_or_hostname)
          hostname = URI.parse(url_or_hostname).host
          allowed_hosts.include?(hostname)
        end

        private

        def regional_oauth_endpoint_url(region = 'us')
          crm_oauth_server_config = OauthServerinfo.having_region_alpha2(region).first
          unless crm_oauth_server_config.present?
            exception =
              ::LarCity::Errors::Unknown3rdPartyHostError
                .new("Unsupported 3rd party service region: #{region}")
            raise exception
          end

          crm_oauth_server_config.endpoint
        end

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

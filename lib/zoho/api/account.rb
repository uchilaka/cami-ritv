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

        def resource_url(auth: true)
          return auth_endpoint_url if auth

          base_url(auth:)
        end

        def base_url(auth: false)
          return 'https://accounts.zoho.com' if auth

          super
        end

        def module_name
          name.to_s.split('::').last.pluralize.capitalize
        end
      end
    end
  end
end

# frozen_string_literal: true

module Zoho
  class Credentials
    class << self
      def client_id
        ENV.fetch('ZOHO_CLIENT_ID', Rails.application.credentials&.zoho&.client_id)
      end

      def client_secret
        ENV.fetch('ZOHO_CLIENT_SECRET', Rails.application.credentials&.zoho&.client_secret)
      end

      def redirect_uri
        ENV.fetch('ZOHO_REDIRECT_URI', Rails.application.credentials&.zoho&.redirect_uri)
      end

      def soid
        crm_org_id = ENV.fetch('CRM_ORG_ID', Rails.application.credentials&.zoho&.org_id)
        return nil unless crm_org_id.present?

        "ZohoCRM.#{crm_org_id}"
      end
    end
  end
end

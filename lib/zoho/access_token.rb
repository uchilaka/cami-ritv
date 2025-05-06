# frozen_string_literal: true

module Zoho
  class AccessToken
    # About class (instance) variables: https://www.ruby-lang.org/en/documentation/faq/8/
    @@connection = nil

    class << self
      def generate
        response = connection.post('/oauth/v2/token', token_params)
        response.body
      end

      # Docs on scopes: https://www.zoho.com/crm/developer/docs/api/v7/scopes.html
      def supported_scopes
        %w[
          ZohoCRM.modules.accounts.ALL
          ZohoCRM.modules.appointments.ALL
          ZohoCRM.modules.contacts.ALL
          ZohoCRM.modules.deals.ALL
          ZohoCRM.modules.invoices.ALL
          ZohoCRM.modules.leads.ALL
          ZohoCRM.modules.notes.ALL
          ZohoCRM.modules.products.ALL
          ZohoCRM.modules.tasks.ALL
          ZohoCRM.modules.vendors.ALL
        ]
      end

      def resource_url
        "#{API::Account.resource_url}/oauth/v2/token"
      end

      private

      def connection
        @@connection ||= Faraday.new(url: API::Account.resource_url(auth: true)) do |b|
          b.request :url_encoded
          b.response :json
          b.response :logger if Rails.env.development?
        end
      end

      def token_params
        {
          client_id: Credentials.client_id,
          client_secret: Credentials.client_secret,
          grant_type: 'client_credentials',
          soid: Credentials.soid,
          scope: supported_scopes.join(',')
        }
      end

      def client_id
        Rails.application.credentials&.zoho&.client_id
      end

      def client_secret
        Rails.application.credentials&.zoho&.client_secret
      end
    end
  end
end

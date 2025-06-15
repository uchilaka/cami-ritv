# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V2::Webhooks::Notion::Events', type: :request do
  let(:deal_database_id) { SecureRandom.uuid }
  let(:integration_id) { SecureRandom.uuid }
  let(:integration_name) { 'CAMI Lab Integration' }

  path '/api/v2/webhooks/notion/events' do
    # let(:deal_database_id) { SecureRandom.uuid }
    # let(:integration_id) { SecureRandom.uuid }
    # let(:integration_name) { 'CAMI Lab Integration' }
    before do
      Fabricate(:notion_webhook, data: { integration_id:, integration_name:, deal_database_id: })
      allow(ActiveSupport::SecurityUtils).to \
        receive(:secure_compare).and_return(true)
    end

    around do |example|
      Flipper.enable(:feat__notion_webhook_skip_signature_validation)
      example.run
    end

    after do
      allow(ActiveSupport::SecurityUtils).to \
        receive(:secure_compare).and_call_original
    end

    post 'Creates a Notion webhook event' do
      tags 'Webhooks'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :event_params, in: :body, schema: {
        type: :object,
        properties: {
          verification_token: {
            type: :string,
            description: 'Verification token for the webhook, sent once during Notion webhook setup',
            nullable: true,
          },
          event: {
            '$ref': '#/components/schemas/notion_event',
          },
        },
      }

      response '200', 'event processed' do
        let(:testing_id) { SecureRandom.hex(4) }
        let(:event_data) do
          {
            id: SecureRandom.uuid,
            timestamp: Time.current.iso8601,
            workspace_id: "workspace-#{testing_id}",
            workspace_name: 'Test Workspace',
            subscription_id: "subscription-#{testing_id}",
            integration_id: "integration-#{testing_id}",
            attempt_number: 1,
            type: 'page.created',
            data: {
              parent: {
                id: deal_database_id,
                type: 'database',
              },
            },
          }
        end
        let(:event_params) do
          {
            **event_data,
            event: event_data,
          }
        end

        run_test! do
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'invalid event data' do
        let(:event_params) do
          {
            event: {
              # Missing required data attribute
              timestamp: Time.current.iso8601,
            },
          }
        end

        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to have_key('errors')
        end
      end
    end
  end

  # This context is for tests that don't fit neatly in the Swagger documentation
  # but still need to be tested
  context 'when validating Notion signature' do
    before do
      Fabricate(:notion_webhook, data: { integration_id:, integration_name:, deal_database_id: })
      allow(ActiveSupport::SecurityUtils).to \
        receive(:secure_compare).and_return(true)
    end

    # This test is pending because signature verification is commented out in the controller
    xit 'verifies the Notion signature header' do
      # Mock the headers with a valid signature
      headers = { 'X-Notion-Signature' => 'valid-signature' }

      # TODO: Update the JSON schema to support the verification token with everything else nullable
      valid_event_params = {
        verification_token: SecureRandom.hex(24),
      }

      post('/api/v2/webhooks/notion/events', params: valid_event_params, headers:)
      expect(response).to have_http_status(:ok)
    end
  end
end

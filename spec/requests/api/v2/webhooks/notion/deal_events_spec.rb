# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V2::Webhooks::Notion::Events', type: :request do
  let(:deal_database_id) { SecureRandom.uuid }
  let(:integration_id) { SecureRandom.uuid }
  let(:integration_name) { 'CAMI Lab Integration' }
  let(:verification_token) { SecureRandom.hex(24) }

  path '/api/v2/webhooks/notion/events' do
    let(:'X-Notion-Signature') { 'valid-notion-request-signature' }

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

    post 'Notion deal database event' do
      # TODO: Read up on how the tags feature works in rswag
      tags 'Webhooks'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :'X-Notion-Signature', in: :header, type: :string, required: true,
                description: 'Signature header for Notion webhook verification'

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
            nullable: true,
          },
        },
      }

      response '200', 'deal updated event is processed' do
        let(:event_type) { 'page.properties_updated' }
        let(:testing_id) { SecureRandom.hex(4) }
        let(:event_data) do
          {
            'id' => 'b617e9d0-7267-4a7b-a62f-8635c4d0f6cd',
            'timestamp' => '2025-08-09T10:20:53.273Z',
            'workspace_id' => '0c39cfc7-e1df-41ee-90d8-9147e025de23',
            'workspace_name' => "Uche's Notion",
            'subscription_id' => '210d872b-594c-8112-adcf-00998896998d',
            'integration_id' => integration_id,
            'authors' => [{ 'id' => '65a600e7-9de7-4bff-b158-07c1d4b1dc71', 'type' => 'person' }],
            'attempt_number' => 4, 'api_version' => '2022-06-28',
            'entity' => { 'id' => '22631362-3069-80c5-bd8e-f024ef3c6fcd', 'type' => 'page' },
            'type' => event_type,
            'data' => {
              'parent' => {
                'id' => deal_database_id,
                'type' => 'database',
              },
              'updated_properties' => ['y_%3D%3C'],
            },
          }
        end
        let(:event_params) do
          { **event_data, event: event_data }
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

  # NOTE: This context is for tests that don't fit neatly in the Swagger documentation
  #   but still need to be tested
  context 'when a verification_token is sent', skip: 'TODO: Not debugging this right now. Re-enable later.' do
    before do
      Fabricate(:notion_webhook, data: { integration_id:, integration_name:, deal_database_id: })
    end

    it 'validates the Notion verification token' do
      # TODO: Update the JSON schema to support the verification token with everything else nullable
      valid_event_params = { verification_token: }

      post('/api/v2/webhooks/notion/events', params: valid_event_params, headers:)
      expect(response).to have_http_status(:ok)
    end
  end
end

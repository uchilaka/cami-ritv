# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V2::Webhooks::Notion::Events', type: :request do
  let(:vendor_database_id) { SecureRandom.uuid }
  let(:integration_id) { SecureRandom.uuid }
  let(:integration_name) { 'CAMI Lab Integration' }
  let(:verification_token) { SecureRandom.hex(24) }
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
          'id' => vendor_database_id,
          'type' => 'database',
        },
        'updated_properties' => ['y_%3D%3C'],
      },
    }
  end

  path '/api/v2/webhooks/{slug}/events' do
    parameter name: :'X-Notion-Signature', in: :header, schema: { type: :string }, required: true,
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
    parameter name: :slug, in: :path, schema: { type: :string }, required: true, description: 'Webhook slug (e.g., notion)'

    let(:'X-Notion-Signature') { 'valid-notion-request-signature' }
    let(:slug) { 'notion' }

    before do
      Flipper.enable(:feat__notion_webhook_skip_signature_validation)
      Flipper.enable(:feat__notion_use_persist_event_workflow)
      Fabricate(:notion_webhook, data: { integration_id:, integration_name:, vendor_database_id: })
      allow(ActiveSupport::SecurityUtils).to \
        receive(:secure_compare).and_return(true)
    end

    after do
      allow(ActiveSupport::SecurityUtils).to \
        receive(:secure_compare).and_call_original
      Flipper.disable(:feat__notion_use_persist_event_workflow)
    end

    post 'Notion vendor database event' do
      # TODO: Read up on how the tags feature works in rswag
      tags 'Webhooks'
      consumes 'application/json'
      produces 'application/json'

      response '200', 'update event is processed' do
        let(:event_type) { 'page.properties_updated' }
        let(:testing_id) { SecureRandom.hex(4) }
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

      context 'when a verification_token is sent' do
        post 'Notion deal verification token request' do
          produces 'application/json'
          consumes 'application/json'

          response '200', 'token is valid' do
            let(:event_params) { { verification_token: } }

            run_test! do
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end
end

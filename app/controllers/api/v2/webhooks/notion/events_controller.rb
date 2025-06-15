# frozen_string_literal: true

module API
  module V2
    module Webhooks
      module Notion
        class EventsController < ApplicationController
          before_action :set_event, only: %i[create]
          skip_before_action :authenticate_user!
          # TODO: Implement a request verification strategy that's compatible with Rails'
          #   CSRF protection and leverages verified_request? instead of skipping it entirely.
          # CSRF protection is enabled by default. Custom request verification is integrated with `verified_request?`.
          # before_action :validate_request_signature, only: %i[create]

          # TODO: Validate event payload
          #   https://developers.notion.com/reference/webhooks#step-3-validating-event-payloads-recommended
          def create
            result =
              ::Notion::HandlePageEventWorkflow.call(webhook:, event: @event)
            http_status = result.response_http_status || :server_error
            head http_status
          end

          protected

          def webhook
            @webhook ||= ::Webhook.find_by(slug: 'notion')
          end

          private

          def request_signature_header
            request.headers['HTTP_X_NOTION_SIGNATURE']
          end

          def set_event
            @event = ::Notion::Event.new(webhook_event_params)
            @event.validate!
          rescue ActiveModel::ValidationError => e
            render json: { errors: e.message }, status: :unprocessable_entity
          end

          def webhook_verification_params
            params.expect(:verification_token)
          end

          def webhook_event_params
            params
              .expect(
                event: [
                  :id,
                  :type,
                  :timestamp,
                  :workspace_id,
                  :workspace_name,
                  :subscription_id,
                  :integration_id,
                  :attempt_number,
                  entity: %i[id type],
                  data: [
                    parent: %i[id type],
                  ],
                  authors: [
                    %i[id type],
                  ],
                ]
              )
          end

          # Only sent during webhook setup for verification
          def request_verification_token
            webhook_verification_params[:verification_token]
          end

          def verified_request?
            super || begin
              result =
                ::Notion::VerifyRequestWorkflow
                  .call(webhook:, signature_header: request_signature_header)
              result.success?
            end
          end

          def validate_request_signature
            render json: { error: 'Invalid signature' }, status: :unauthorized unless verified_request?
          end
        end
      end
    end
  end
end

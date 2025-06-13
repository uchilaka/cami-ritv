# frozen_string_literal: true

module API
  module V2
    module Webhooks
      module Notion
        class EventsController < ApplicationController
          # prepend_before_action :set_webhook, only: %i[create]
          skip_before_action :authenticate_user!
          skip_before_action :verify_authenticity_token
          before_action :set_event, only: %i[create]

          # TODO: Validate event payload
          #   https://developers.notion.com/reference/webhooks#step-3-validating-event-payloads-recommended
          def create
            head :ok
          end

          # protected
          #
          # def verified_request?
          #   @webhook.present?
          # end

          private

          def request_signature_header
            headers['X-Notion-Signature']
          end

          def set_webhook
            # TODO: Verification tokens aren't sent with each request
            @webhook = ::Webhook.find_by(slug: 'notion', verification_token:)
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

          def verification_token
            webhook_verification_params[:verification_token]
          end
        end
      end
    end
  end
end

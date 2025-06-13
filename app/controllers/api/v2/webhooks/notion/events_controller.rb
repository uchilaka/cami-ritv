# frozen_string_literal: true

module API
  module V2
    module Webhooks
      module Notion
        class EventsController < ApplicationController
          before_action :set_event, only: %i[create]
          skip_before_action :authenticate_user!
          skip_forgery_protection only: %i[create]
          # skip_before_action :verify_authenticity_token, only: %i[create]
          prepend_before_action :set_webhook, only: %i[create]

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
            request.headers['HTTP_X_NOTION_SIGNATURE']
          end

          def set_webhook
            @webhook = ::Webhook.find_by(slug: 'notion')
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
          def verification_token
            webhook_verification_params[:verification_token]
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module API
  module V2
    module Webhooks
      module Notion
        class EventsController < ApplicationController
          before_action :set_event, only: %i[create]
          skip_before_action :authenticate_user!
          skip_forgery_protection only: %i[create]
          before_action :validate_request_signature, only: %i[create]

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

          def generate_expected_signature
            verification_token = webhook.verification_token
            body_json = JSON.generate(verification_token:)
            digest = OpenSSL::HMAC.hexdigest('SHA256', verification_token, body_json)
            "sha256=#{digest}"
          end

          def is_trusted_request?
            # (UTF-8) sha256=56ff3c6e975d6ebc973882a5223c6daf7f655294d7b64a72f5e662317253d859
            expected_signature = generate_expected_signature
            # (ASCII-8BIT) sha256=7482396002976ad1005dfb6b8eb7de70e30d48f76a8a124f4d3dfe1a2fec3d97
            signature_header = request_signature_header
            ActiveSupport::SecurityUtils.secure_compare(expected_signature, signature_header)
          end

          def validate_request_signature
            unless is_trusted_request?
              render json: { error: 'Invalid signature' }, status: :unauthorized
            end
          end
        end
      end
    end
  end
end

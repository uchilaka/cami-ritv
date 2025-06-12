# frozen_string_literal: true

module API
  module V2
    module Webhooks
      class EventsController < ApplicationController
        before_action :set_webhook, only: %i[create]
        skip_before_action :authenticate_user!
        skip_before_action :verify_authenticity_token

        # TODO: Validate event payload
        #   https://developers.notion.com/reference/webhooks#step-3-validating-event-payloads-recommended
        def create; end

        private

        def set_webhook
          @webhook = Webhook.find_by(slug:, verification_token:)
        end

        def webhook_event_params
          params
            .expect(
            :slug,
              :verification_token,
              event: [
                :id,
                :type,
                :timestamp,
                :workspace_id,
                :workspace_name,
                :subscription_id,
                :integration_id,
                :attempt_number,
                entity: [:id, :type],
                data: [
                  parent: [:id, :type]
                ],
                authors: [
                  [:id, :type]
                ],
              ]
            )
        end

        def slug
          webhook_event_params[:slug]
        end

        def verification_token
          webhook_event_params[:verification_token]
        end
      end
    end
  end
end

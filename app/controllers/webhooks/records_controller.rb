# frozen_string_literal: true

module Webhooks
  class RecordsController < ApplicationController
    def index; end

    def show; end

    protected

    def webhook
      @webhook ||= authorize Webhook.friendly.find(webhook_id)
    end

    def event
      @event ||=
        if event_id.blank?
          nil
        else
          # TODO: add test coverage for this use of .friendly.find in a generic event query
          authorize webhook.generic_events.friendly.find(event_id)
        end
    rescue ActiveRecord::RecordNotFound
      nil
    end

    private

    def webhook_id
      id, webhook_id = identifiers
      webhook_id || id
    end

    def event_id
      id, webhook_id = identifiers
      return nil if webhook_id.blank?

      id
    end

    def identifiers
      webhook_record_params.values_at :id, :webhook_id
    end

    def webhook_record_params
      params.permit(:id, :webhook_id)
    end
  end
end

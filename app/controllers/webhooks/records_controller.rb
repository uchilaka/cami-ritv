# frozen_string_literal: true

module Webhooks
  class RecordsController < ApplicationController
    load_console :index, :show

    def index
      result = workflow_by_action.call(webhook:, event:)
      @records = result.records

      case webhook_id
      when 'notion'
        # Render notion index view
        render 'webhooks/notion/records/index'
      else
        # Render default index view
        render 'webhooks/records/index'
      end
    end

    def show
      result = workflow_by_action.call(webhook:, source_event: event)
      # @record = result.records.find { |r| r.id == webhook_record_params[:id] }
      #
      # if @record.nil?
      #   flash[:alert] = "Record not found for ID: #{webhook_record_params[:id]}"
      #   redirect_to action: :index
      # else
      #   case webhook_id
      #   when 'notion'
      #     # Render notion show view
      #     render 'webhooks/notion/records/show'
      #   else
      #     # Render default show view
      #     render 'webhooks/records/show'
      #   end
      # end
      case webhook_id
      when 'notion'
        # Render notion show view
        render 'webhooks/notion/records/show'
      else
        # Render default show view
        render 'webhooks/records/show'
      end
    end

    protected

    def workflow_by_action
      @workflow_by_action ||= webhook.actions.send(action_name).workflow_klass
    end

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

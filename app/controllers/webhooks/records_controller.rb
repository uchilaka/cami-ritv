# frozen_string_literal: true

module Webhooks
  class RecordsController < ApplicationController
    load_console :index, :show

    def index
      # TODO: Add test coverage for this use of workflow_by_action on :index
      result = workflow_by_action.call(webhook:, event:, controller: self)
      @records = result.records

      view_path =
        if view_exists?(record_view_by_action)
          record_view_by_action
        else
          "webhooks/records/#{action_name}"
        end
      render view_path
    end

    def show
      # TODO: Add test coverage for this use of workflow_by_action on :show
      result = workflow_by_action.call(webhook:, source_event: event, remote_record_id: record_id)
      raise LarCity::Errors::UnprocessableEntity, result.error if result.failure?

      if result.failure?
        Rails.logger.error(
          'Failed to download webhook record',
          webhook_id:, error: result.error, message: result.message
        )
        flash[:alert] = "Failed to process record: #{result.error}"
        redirect_to action: :index and return
      else
        flash[:success] = "Successfully fetched #{webhook.slug.humanize} record"
      end

      # TODO: Implement webhook name to display here
      @record = result.record
    end

    protected

    def record_view_by_action
      path_prefix = _prefixes.first.gsub('webhooks', "webhooks/#{webhook_id}")
      "#{path_prefix}/#{action_name}"
    end

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

    def view_exists?(relative_path, partial: false)
      lookup_context.exists?(relative_path, [], partial)
    end

    private

    def record_id
      id, webhook_id, _event_id = identifiers
      return nil if webhook_id.blank?

      id
    end

    def webhook_id
      id, webhook_id, _event_id = identifiers
      webhook_id || id
    end

    def event_id
      id, webhook_id, _event_id = identifiers
      return nil if webhook_id.blank?

      id
    end

    def identifiers
      webhook_record_params.values_at :id, :webhook_id, :event_id
    end

    def webhook_record_params
      params.permit(:id, :event_id, :webhook_id)
    end
  end
end

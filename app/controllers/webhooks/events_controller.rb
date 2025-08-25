# frozen_string_literal: true

module Webhooks
  class EventsController < ::ApplicationController
    # Make sure the webhook is loaded before any action
    before_action :webhook
    before_action :event, except: %i[index]

    def index
      @query = GenericEvent.ransack(search_query.predicates)
      @query.sorts = search_query.sorters if search_query.sorters.any?
      @events = policy_scope(@query.result(distinct: true)).paginate(page, GenericEvent.page_limit)
      @sql = Rails.env.development? ? @query.result.to_sql : nil
    end

    def show; end

    protected

    def event
      @event ||= authorize GenericEvent.friendly.find(event_id)
    end

    def webhook
      @webhook ||= authorize Webhook.friendly.find(events_params[:webhook_id])
    end

    def page
      @page ||= params[:page] || 1
    end

    private

    def event_id
      return events_params[:id] if webhook.present?

      events_params[:event_id]
    end

    def search_query
      @search_query ||= ::Webhooks::EventSearchQuery.new(
        events_params[:q],
        params: events_params,
        fields: %w[slug status]
      )
    end

    def events_params
      if params[:f].is_a?(Array) || params[:s].is_a?(Array)
        event_search_array_params
      else
        event_search_hash_params
          .reverse_merge(s: { createdAt: 'desc' })
      end
    rescue ActionController::ParameterMissing => e
      raise ActionController::BadRequest, e.message
    end

    def event_search_hash_params
      params.permit(*event_search_common_params, f: {}, s: {})
    end

    def event_search_array_params
      params.permit(*event_search_common_params, f: %i[field value], s: %i[field direction])
    end

    def event_search_common_params
      %i[webhook_id event_id id page q]
    end
  end
end

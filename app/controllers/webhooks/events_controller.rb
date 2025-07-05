# frozen_string_literal: true

module Webhooks
  class EventsController < ::ApplicationController
    def index
      @query = policy_scope(GenericEvent).ransack(search_query.predicates)
      @query.sorts = search_query.sorters if search_query.sorters.any?
      @events = @query.result.paginate(page, GenericEvent.page_limit)
    end

    def show; end

    protected

    def event
      @event ||=
        if events_params[:event_id].blank?
          nil
        else
          authorize webhook.generic_events.friendly.find(events_params[:event_id])
        end
    end

    def webhook
      @webhook ||= authorize Webhook.friendly.find(events_params[:webhook_id])
    end

    def page
      @page ||= params[:page] || 1
    end

    private

    def search_query
      @search_query ||= ::Webhooks::EventSearchQuery.new(
        events_params[:q],
        params: events_params,
        fields: %w[slug status eventable_type]
      )
    end

    def events_params
      params.permit(:webhook_id, :event_id, :page, :q)
    end
  end
end

module Webhooks
  module EventsHelper
    def webhook_events_pagination_enabled?
      @webhook_events_pagination_enabled ||=
        Flipper.enabled?(:feat__webhook_events_pagination, current_user)
    end
  end
end

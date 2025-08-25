# frozen_string_literal: true

module Webhooks
  module EventsHelper
    def webhook_events_pagination_enabled?
      @webhook_events_pagination_enabled ||=
        Flipper.enabled?(:feat__webhook_events_pagination, current_user)
    end

    def webhook_event_action_menu_view
      @webhook_event_action_menu_view ||=
        begin
          path_prefix = controller._prefixes.first
          specific_path_prefix = path_prefix.gsub('webhooks', "webhooks/#{@webhook.slug}")
          menu_path = "#{specific_path_prefix}/list_item/action_menu"
          if controller.view_exists?(menu_path, partial: true)
            menu_path
          else
            "#{path_prefix}/list_item/action_menu"
          end
        end
    end
  end
end

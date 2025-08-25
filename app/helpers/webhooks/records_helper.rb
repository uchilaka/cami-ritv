# frozen_string_literal: true

module Webhooks
  module RecordsHelper
    def webhook_record_view_partial_path
      case @webhook&.slug
      when 'notion'
        "webhooks/#{@webhook.slug}/#{webhook_record_view_name_from_action}"
      else
        "webhooks/records/#{webhook_record_view_name_from_action}"
      end
    end

    def webhook_record_view_name_from_action
      case action_name
      when 'new', 'create', 'edit', 'update'
        'form'
      else
        'record'
      end
    end

    def notion_deals_pagination_enabled?
      @notion_deals_pagination_enabled ||= Flipper.enabled? :feat__notion_deals_pagination, current_user
    end
  end
end

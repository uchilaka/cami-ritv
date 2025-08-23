# frozen_string_literal: true

module Webhooks
  module RecordsHelper
    def record_view_partial_path
      case @webhook&.slug
      when 'notion'
        "webhooks/#{@webhook.slug}/#{record_view_name_from_action}"
      else
        "webhooks/records/#{record_view_name_from_action}"
      end
    end

    def record_view_name_from_action
      case action_name
      when 'new', 'create', 'edit', 'update'
        'form'
      else
        'record'
      end
    end
  end
end

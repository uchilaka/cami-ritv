# frozen_string_literal: true

module WebhooksHelper
  def webhook_view_partial_path
    case @webhook&.slug
    when 'notion'
      "webhooks/#{@webhook.slug}/#{webhook_view_name_from_action}"
    else
      "webhooks/#{webhook_view_name_from_action}"
    end
  end

  def webhook_view_name_from_action
    case action_name
    when 'new', 'create', 'edit', 'update'
      'form'
    else
      'webhook'
    end
  end
end

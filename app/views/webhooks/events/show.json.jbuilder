json.event do
  # Render specific details based on the event type or slug
  case @webhook.slug
  when 'notion'
    json.partial! 'webhooks/notion/events/event', event: @event
  else
    json.partial! 'webhooks/events/event', event: @event
  end
end

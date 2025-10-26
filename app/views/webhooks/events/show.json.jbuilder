json.event do
  # Render specific details based on the event type or slug
  case @event
  when Notion::DealCreatedEvent, Notion::DealUpdatedEvent
    json.partial! 'webhooks/notion/deals/event', event: @event
  when Notion::VendorCreatedEvent, Notion::VendorUpdatedEvent
    json.partial! 'webhooks/notion/event', event: @event
  else
    json.partial! 'webhooks/events/event', event: @event
  end
end

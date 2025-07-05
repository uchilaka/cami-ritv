case @webhook&.slug
when 'notion'
  # Render Notion specific events
  json.array! @events, partial: 'webhooks/notion/events/event', as: :event
else
  # Render generic events
  json.array! @events, partial: 'webhooks/events/event', as: :event
end

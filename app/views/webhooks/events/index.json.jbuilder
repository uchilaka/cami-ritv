json.query do
  # json.page @page
  # json.total @query.result.count
  # json.per_page GenericEvent.page_limit
  # json.sorts @query.sorts.map(&:to_s)
  # json.search_query @search_query.to_h
  json.predicate @search_query.predicates
end

json.webhook do
  json.extract! @webhook.serializable_hash, :id, :slug, :url, :status
end

json.events do
  case @webhook&.slug
  when 'notion'
    # Render Notion specific events
    json.array! @events, partial: 'webhooks/notion/events/event', as: :event
  else
    # Render generic events
    json.array! @events, partial: 'webhooks/events/event', as: :event
  end
end

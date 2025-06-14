# frozen_string_literal: true

Fabricator('Notion::Entity') do
  id { nil }
  type { 'generic' }
  data { {} }

  after_build do |entity|
    entity.data ||= {}
    entity.id ||= entity.data[:id]
  end
end

Fabricator(:notion_entity, from: 'Notion::Entity')

Fabricator(:notion_page, from: 'Notion::Entity') do
  type { 'page' }
end

Fabricator(:notion_database, from: 'Notion::Entity') do
  type { 'database' }
end

Fabricator(:notion_event, from: 'Notion::Entity') do
  type { 'page.created' }
end

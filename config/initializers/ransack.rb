# frozen_string_literal: true

Ransack.configure do |config|
  config.add_predicate 'jcont',
                       arel_predicate: 'contains',
                       formatter: proc { |v| JSON.parse(v) }
  config.add_predicate 'jcont_any',
                       arel_predicate: 'contains_any',
                       formatter: proc { |v| JSON.parse(v) }
  config.add_predicate 'jstart',
                       arel_predicate: 'starts_with',
                       formatter: proc { |v| JSON.parse(v) }
  config.add_predicate 'jend',
                       arel_predicate: 'ends_with',
                       formatter: proc { |v| JSON.parse(v) }
end

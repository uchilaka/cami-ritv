# frozen_string_literal: true

module Webhooks
  class EventSearchQuery < ::SearchQuery
    def initialize(query_string, params: {}, fields: [])
      super(query_string, params:)
      @fields = fields
      build(fields:)
    end

    def build(fields: [])
      compose_predicates(*fields)
    end

    protected

    def compose_predicates(*fields)
      search_fields = (%w[key] + fields).uniq
      metadatum_search_predicate =
        GenericEvent
          .fuzzy_search_predicate_key(
            'key',
            model_name: :appendable,
            association: 'Metadatum',
            polymorphic: true,
            matcher: nil
          )
      search_fields = (search_fields + %w[event_type]).uniq
      event_search_predicate =
        GenericEvent.fuzzy_search_predicate_key(*search_fields, matcher: nil)
      compound_cont_predicate =
        [event_search_predicate, metadatum_search_predicate].join('_or_')
      @predicates["#{compound_cont_predicate}_cont"] = query_string
    end
  end
end

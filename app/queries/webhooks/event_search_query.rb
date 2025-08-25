# frozen_string_literal: true

module Webhooks
  class EventSearchQuery < ::SearchQuery
    def initialize(query_string, params: {}, fields: [])
      super(query_string, params:) do
        @fields = fields
        build
      end
    end

    def build
      compose_predicates
      compose_sorters
    end

    protected

    def fields
      @fields || []
    end

    def compose_sorters
      return sorters if sort_params.blank?

      @sorters =
        if sort_params.is_a?(Hash)
          sort_params.each_with_object([]) do |(field, direction), array|
            array << compose_sorter_clause(field:, direction:)
          end
        elsif sort_params.is_a?(Array)
          sort_params.each_with_object([]) do |sorter, array|
            field, direction = sorter.values_at 'field', 'direction'
            array << compose_sorter_clause(field:, direction:)
          end
        else
          sorters
        end
    end

    def compose_filters
      return filters if filter_params.blank?

      @filters =
        if filter_params.is_a?(Hash)
          filter_params
        elsif filter_params.is_a?(Array)
          filter_params.each_with_object({}) do |filter, hash|
            # Only support filtering on specified fields
            next if fields.present? && fields.exclude?(filter['field'])

            hash[filter['field']] = filter['value']
          end
        else
          filters
        end
    end

    def compose_predicates
      @predicates =
        if compose_filters.present?
          filters.each_with_object({}) do |(field, value), predicates|
            case field
            when 'status'
              predicates[:status_eq] = value.downcase
            else
              predicates[:"#{field}_cont"] = value
            end
          end
        else
          {}
        end
      return predicates unless query_string.present?

      search_fields = (fields + %w[slug status]).uniq
      metadatum_search_predicate =
        GenericEvent
          .fuzzy_search_predicate_key(
            'key',
            model_name: :appendable,
            association: 'Metadatum',
            polymorphic: true,
            matcher: nil
          )
      event_search_predicate =
        GenericEvent.fuzzy_search_predicate_key(*search_fields, matcher: nil)
      compound_cont_predicate =
        [event_search_predicate, metadatum_search_predicate].join('_or_')
      @predicates["#{compound_cont_predicate}_cont"] = query_string
      @predicates
    end

    def filter_params
      extract_search_params('f')
    end

    def query_param
      params.permit('q')['q']
    end

    def sort_params
      extract_search_params('s', { createdAt: 'desc' })
    end

    private

    def compose_sorter_clause(field:, direction:)
      "#{field.to_s.underscore} #{direction.to_s.upcase}"
    end
  end
end

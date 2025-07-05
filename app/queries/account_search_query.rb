# frozen_string_literal: true

require_relative 'search_query'

class AccountSearchQuery < SearchQuery
  attr_reader :query_string, :params, :filters, :sorters, :predicates

  def build
    compose_predicates
    compose_sorters
  end

  protected

  def compose_predicates
    search_predicate =
      Account
        .fuzzy_search_predicate_key('display_name', 'email', 'slug', 'tax_id')
    @predicates[search_predicate] = query_string
    @predicates
  end

  def compose_sorters
    return sorters if sort_params.blank?

    @sorters =
      sort_params.each_with_object([]) do |(field, direction), clauses|
        clauses << compose_sorter_clause(field:, direction:)
      end
  end

  def compose_sorter_clause(field:, direction: 'asc')
    "#{field.underscore} #{direction}".strip
  end

  def filter_params
    extract_search_params(:f)
  end

  def sort_params
    extract_search_params(:s, [])
  end
end

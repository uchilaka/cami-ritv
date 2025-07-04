# frozen_string_literal: true

require_relative 'search_query'

class InvoiceSearchQuery < SearchQuery
  def build
    compose_predicates
    compose_sorters
  end

  protected

  def compose_predicates
    @predicates =
      if compose_filters.present?
        filters.each_with_object({}) do |(field, value), predicates|
          case field
          when 'dueAt'
            predicates[:due_at_gteq] = value
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

    account_search_predicate =
      Invoice.fuzzy_search_predicate_key(
        'display_name', 'email',
        model_name: :invoiceable,
        association: 'Account',
        polymorphic: true,
        matcher: nil
      )
    invoice_search_predicate =
      Invoice.fuzzy_search_predicate_key('invoice_number', matcher: nil)
    compound_cont_predicate =
      [invoice_search_predicate, account_search_predicate].join('_or_')
    @predicates["#{compound_cont_predicate}_cont"] = query_string
  end

  def compose_filters
    return filters if filter_params.blank?

    @filters =
      if filter_params.is_a?(Hash)
        filter_params
      elsif filter_params.is_a?(Array)
        filter_params.each_with_object({}) do |filter, hash|
          hash[filter['field']] = filter['value']
        end
      else
        filters
      end
  end

  def compose_sorters
    return sorters if sort_params.blank?

    @sorters =
      if sort_params.is_a?(Array)
        sort_params.each_with_object([]) do |sorter, clauses|
          field, direction = sorter.values_at 'field', 'direction'
          clauses << compose_sorter_clause(field:, direction:)
        end
      elsif sort_params.is_a?(Hash)
        sort_params.each_with_object([]) do |(field, direction), clauses|
          clauses << compose_sorter_clause(field:, direction:)
        end
      else
        sorters
      end
  end

  def filter_params
    extract_search_params('f')
  end

  def query_param
    params.permit('q')['q']
  end

  def sort_params
    extract_search_params('s', [])
  end

  private

  def compose_sorter_clause(field:, direction: 'asc')
    case field
    when 'dueAt'
      "due_at #{direction}".strip
    else
      "#{field.parameterize} #{direction}".strip
    end
  end
end

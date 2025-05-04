# frozen_string_literal: true

class SearchQuery
  attr_reader :query_string, :params, :filters, :sorters, :predicates

  def initialize(query_string = nil, params: {})
    @query_string = query_string
    @params = params
    @filters ||= {}
    @sorters ||= []
    @predicates ||= {}
    build
  end

  def extend(params)
    @params = @params.merge(params)
    rebuild
  end

  def build
    raise NotImplementedError, "#{self.class.name} must implement #build"
  end

  alias rebuild build

  protected

  def query_param
    raise NotImplementedError, "#{self.class.name} must implement #query_param"
  end

  def compose_filters
    raise NotImplementedError, "#{self.class.name} must implement #compose_filters"
  end

  def compose_predicates
    raise NotImplementedError, "#{self.class.name} must implement #compose_predicates"
  end

  def compose_sorters
    raise NotImplementedError, "#{self.class.name} must implement #compose_sorters"
  end

  def extract_search_params(key, default_value = {})
    # TODO: Filter params here based on whether we're trying for an array or a hash
    if params[key].present?
      begin
        {}.merge(params[key] || {})
      rescue TypeError => _e
        params[key].to_a
      end
    else
      default_value
    end
  end
end

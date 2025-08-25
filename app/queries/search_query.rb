# frozen_string_literal: true

class SearchQuery
  attr_reader :query_string, :params, :filters, :sorters, :predicates

  def initialize(query_string = nil, params: {})
    @query_string = query_string
    @params = params
    @filters ||= {}
    @sorters ||= []
    @predicates ||= {}
    if block_given?
      yield self
    else
      build
    end
  end

  def extend(params)
    @params = @params.merge(params)
    rebuild
  end

  def build(fields: [])
    raise NotImplementedError, "#{self.class.name} must implement #build"
  end

  alias rebuild build

  protected

  def query_param
    raise NotImplementedError, "#{self.class.name} must implement #query_param"
  end

  def filter_params
    raise NotImplementedError, "#{self.class.name} must implement #filter_params"
  end

  def sort_params
    raise NotImplementedError, "#{self.class.name} must implement #sort_params"
  end

  def compose_filters(*fields)
    raise NotImplementedError, "#{self.class.name} must implement #compose_filters"
  end

  def compose_predicates(*fields)
    raise NotImplementedError, "#{self.class.name} must implement #compose_predicates"
  end

  def compose_sorters(*fields)
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

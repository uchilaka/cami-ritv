# frozen_string_literal: true

module Pagination
  extend ActiveSupport::Concern
  included do
    extend ClassMethods

    scope :paginate, lambda { |page = 1, per_page = 25|
      offset((page - 1) * per_page).limit(per_page)
    }
  end

  module ClassMethods
    # Parse the class name to calculate a conventional environment-specific page limit.
    def page_limit
      klass_name = name.demodulize.underscore
      default_value = ENV.fetch("#{klass_name.upcase}_PAGE_LIMIT", nil)
      return default_value.to_i if default_value.present?

      case klass_name
      when 'generic_event', 'webhook_record'
        50
      else
        25 # Default page limit for other classes
      end
    end
  end
end

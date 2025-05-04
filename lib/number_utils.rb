# frozen_string_literal: true

require 'active_support/number_helper'

# @deprecated Use monetize instead in currency implementations
module NumberUtils
  class << self
    include ActiveSupport::NumberHelper

    def as_money(val)
      num_val = val.is_a?(String) ? val.to_d : val
      NumberUtils.number_to_currency(num_val, unit: '', delimiter: ',', separator: '.')
    end

    def as_cents(val)
      val.is_a?(String) ? (val.to_d * 100.0).round : 0
    end
  end
end

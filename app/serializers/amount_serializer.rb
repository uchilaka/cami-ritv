# frozen_string_literal: true

# @deprecated Use `MonetaryValueSerializer` instead.
class AmountSerializer < AdhocSerializer
  def attributes
    { value:, value_in_cents:, currency_code: }
  end

  def value
    NumberUtils.as_money(object['value'])
  end

  def value_in_cents
    NumberUtils.as_cents(object['value'])
  end

  def currency_code
    object['currency_code'] || 'USD'
  end
end

# frozen_string_literal: true

class MonetaryValueSerializer < AdhocSerializer
  def attributes
    { value:, formatted_value:, value_in_cents:, currency_code: }
  end

  def formatted_value
    object.format
  end

  def value
    object.cents / 100.0
  end

  def value_in_cents
    object.cents
  end

  def currency_code
    object.currency.iso_code || 'USD'
  end
end

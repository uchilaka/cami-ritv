# frozen_string_literal: true

class InvoiceAccountSerializer < AdhocSerializer
  def attributes
    {
      given_name:,
      family_name:,
      display_name:,
      email:,
      type:
    }.compact
  end

  def names
    object.dig('billing_info', 'name') || {}
  end

  def given_name
    names['given_name']
  end

  def family_name
    names['family_name'] || names['surname']
  end

  def name_or_default
    names['full_name'] || email
  end

  def display_name
    return business_name || name_or_default if business?

    name_or_default
  end

  def email
    object.dig('billing_info', 'email_address')
  end

  def business_name
    object.dig('billing_info', 'business_name')
  end

  def type
    business? ? 'Business' : 'Individual'
  end

  private

  def business?
    business_name.present?
  end
end

# frozen_string_literal: true

class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    result = IPAddr.new(value)
    unless result.ipv4? || result.ipv6?
      record.errors.add(attribute, I18n.t('globals.validators.errors.invalid_ip_address', value:))
    end
  rescue IPAddr::InvalidAddressError => _e
    record.errors.add(attribute, I18n.t('globals.validators.errors.invalid_ip_address', value:))
  end
end

# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if URI::MailTo::EMAIL_REGEXP.match?(value)

    record.errors.add attribute, (options[:message] || I18n.t('validators.errors.invalid_email', value:))
  end
end

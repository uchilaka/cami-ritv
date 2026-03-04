# frozen_string_literal: true

class UniqueDnsRecordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raise NotImplementedError, 'Subclasses must implement the validate_each method'
  end

  protected

  def matches_any?(record, value)
    matches =
      Domain::Record
        .by_type_domain_and_name(record.type, record.domain_name.hostname, record.name)
    if %w[A CNAME].include?(record.type)
      matches.where.not(id: record.id).any?
    else
      matches.where(value:).where.not(id: record.id).any?
    end
  end

  def set_unique_record_error(record, attribute, value)
    domain_name = record.domain_name.hostname
    record.errors.add(
      attribute,
      I18n.t(
        'globals.validators.errors.must_be_unique_dns_record',
        record_type: record.type, domain_name:, value:
      )
    )
  end
end

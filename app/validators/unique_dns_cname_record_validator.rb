# frozen_string_literal: true

class UniqueDnsCnameRecordValidator < UniqueDnsRecordValidator
  def validate_each(record, attribute, value)
    return unless record.type == 'CNAME'
    return if record.domain_name.blank?
    return unless matches_any?(record, value)

    set_unique_record_error(record, attribute, value)
  end
end

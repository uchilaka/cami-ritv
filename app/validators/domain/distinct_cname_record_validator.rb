# frozen_string_literal: true

module Domain
  class DistinctCnameRecordValidator < DistinctRecordValidator
    def validate_each(record, attribute, value)
      return unless record.record_type == 'CNAME'
      return unless record_matches_any?(record:, type: record.record_type, domain_name: record.domain.hostname, value:)

      record.errors.add(attribute, 'must be unique for CNAME records with the same domain name and value')
    end
  end
end

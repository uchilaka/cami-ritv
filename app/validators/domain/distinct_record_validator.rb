# frozen_string_literal: true

module Domain
  class DistinctRecordValidator < ActiveModel::Validator
    def validate_each(record, attribute, value)
      raise NotImplementedError, 'Subclasses must implement the validate_each method'
    end

    protected

    def record_matches_any?(record:, domain_name:, type:, value:)
      Domain::Record.by_type_domain_and_value(type, domain_name, value).where.not(id: record.id).any?
    end
  end
end

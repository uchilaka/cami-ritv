# frozen_string_literal: true

module Domain
  # TODO: Validate that there are no duplicate "A" records for the same hostname
  #   and related domain name. This is to prevent issues with DNS resolution
  #   and ensure that each hostname has unique "A" records. This validation should
  #   be implemented in the Domain::Record model and should check for existing
  #   "A" records with the same hostname and domain name before allowing a new
  #   "A" record to be created.
  class DistinctARecordValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, _value)
      return unless record.record_type == 'A'
      return unless record_matches_any?(record:, domain_name: record.domain.hostname)

      record.errors.add(attribute, 'must be unique for A records with the same domain name')
    end

    private

    def record_matches_any?(record:, domain_name:, type: 'A')
      Domain::Record.by_type_and_domain(type, domain_name).where.not(id: record.id).any?
    end
  end
end

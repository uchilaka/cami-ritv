# frozen_string_literal: true

module Notion
  class BaseEventValidator < ActiveModel::Validator
    @required_fields = %i[entity_id database_id]

    class << self
      attr_reader :required_fields

      protected

      def set_required_fields(*fields)
        @required_fields = fields
      end
    end

    protected

    def validate_metadatum_presence(record)
      return if record.metadatum.present?
      # Avoid adding duplicate error messages
      return if (record.errors[:metadatum] || []).include?('must exist')

      record.errors.add(:metadatum, :blank, message: 'must exist')
    end

    def validate_required_attributes(record)
      self.class.required_fields.each do |attr|
        record.errors.add(attr, :blank, message: "can't be blank") if record.send(attr).blank?
      end
    end

    def validate_attempt_number(record)
      attempt_number = record.metadatum&.attempt_number
      return if attempt_number.is_a?(Integer) && attempt_number >= 1

      record.errors.add(:attempt_number, :invalid, message: 'must be an integer greater than or equal to 1')
    end
  end
end

# frozen_string_literal: true

module Notion
  class VendorEventValidator < BaseEventValidator
    set_required_fields(*required_fields_for(:vendor_events))

    def validate(record)
      validate_metadatum_presence(record)
      return if record.metadatum.blank?

      validate_required_attributes(record)
      validate_attempt_number(record)
    end
  end
end

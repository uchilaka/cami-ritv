# frozen_string_literal: true

module Zoho
  class AccountSerializer < AdhocSerializer
    def attributes
      @attributes ||=
        if @attributes.blank?
          attr = {
            Email: email,
            Account_Name: company_name,
            Description: description,
            Phone: phone_number,
            Website: website
          }
          attr[:Mobile] = phone_number if has_mobile_number?
          attr.compact
        end
    end

    def email
      object.email
    end

    def company_name
      object.display_name
    end

    def phone_number
      object.phone.try(:[], 'full_e164')
    end

    def phone_number_type
      object.phone.try(:[], 'number_type')
    end

    def website
      object.metadata.try(:[], 'website')
    end

    def description
      return if object.readme.blank?

      html_content = object.readme.to_s
      return if html_content.blank?

      ReverseMarkdown.convert html_content
    end

    def serializable_hash(_options = nil)
      attributes
    end

    def has_mobile_number?
      phone_number_type == 'mobile'
    end
  end
end

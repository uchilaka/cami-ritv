# frozen_string_literal: true

module LarCity
  class SignedGlobalIdTokenizer
    class << self
      def encode(resource, expires_in: nil, purpose: nil)
        options = {}
        options[:expires_in] = expires_in.to_i if expires_in
        options[:for] = purpose if purpose
        resource.to_signed_global_id(**options)
      end

      def decode(token, resource_class, includes: [], purpose: nil)
        resource_class = resource_class.constantize if resource_class.is_a?(String)
        options = { only: resource_class }
        options[:includes] = includes unless includes.blank?
        options[:for] = purpose if purpose
        [GlobalID::Locator.locate_signed(token, options), _extra_data = {}]
      end
    end
  end
end

# frozen_string_literal: true

require 'openssl'
require 'json'

module Notion
  class VerifyRequestWorkflow
    include Interactor

    def self.expected_signature(verification_token:)
      body_json = JSON.generate({ 'verification_token' => verification_token })
      digest = OpenSSL::HMAC.hexdigest('SHA256', verification_token, body_json)
      "sha256=#{digest}"
    end

    def call
      return true if Utils.skip_signature_validation?

      verification_token = context.webhook.verification_token
      expected_signature = self.class.expected_signature(verification_token:)
      result =
        ActiveSupport::SecurityUtils
          .secure_compare(expected_signature, context.signature_header)
      context.fail!(message: 'Invalid signature') unless result
    end
  end
end

# frozen_string_literal: true

require 'openssl'
require 'json'

module Notion
  class VerifyRequestWorkflow
    include Interactor

    def call
      result =
        ActiveSupport::SecurityUtils
          .secure_compare(
            expected_signature,
            context.signature_header
          )
      return true if Flipper.enabled?(:feat__notion_webhook_skip_signature_validation)

      fail!(message: 'Invalid signature') unless result
    end

    private

    def expected_signature
      verification_token = context.webhook.verification_token
      body_json = JSON.generate({ 'verification_token' => verification_token })
      digest = OpenSSL::HMAC.hexdigest('SHA256', verification_token, body_json)
      "sha256=#{digest}"
    end
  end
end

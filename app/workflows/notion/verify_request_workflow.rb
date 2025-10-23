# frozen_string_literal: true

require 'openssl'
require 'json'

module Notion
  class VerifyRequestWorkflow
    include Interactor

    delegate :results, to: :context

    def self.expected_signature(verification_token:)
      body_json = JSON.generate({ 'verification_token' => verification_token })
      digest = OpenSSL::HMAC.hexdigest('SHA256', verification_token, body_json)
      "sha256=#{digest}"
    end

    def initialize(*)
      context.results = []
      super
    end

    def call
      verification_token = context.webhook.verification_token
      expected_signature = self.class.expected_signature(verification_token:)
      result =
        ActiveSupport::SecurityUtils
          .secure_compare(expected_signature, context.signature_header)
      return true if Flipper.enabled?(:feat__notion_webhook_skip_signature_validation)

      context.fail!(message: 'Invalid signature') unless result
      context.results << result
    end

    # private
    #
    # def expected_signature(verification_token:)
    #   # verification_token = context.webhook.verification_token
    #   body_json = JSON.generate({ 'verification_token' => verification_token })
    #   digest = OpenSSL::HMAC.hexdigest('SHA256', verification_token, body_json)
    #   "sha256=#{digest}"
    # end
  end
end

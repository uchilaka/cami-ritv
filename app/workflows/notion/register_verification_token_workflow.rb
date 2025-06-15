# frozen_string_literal: true

module Notion
  # This workflow is responsible for registering a verification token.
  # It is used to verify the connection between Notion and the application.
  class RegisterVerificationTokenWorkflow
    include Interactor

    def call
      webhook = context.webhook
      if webhook.nil?
        message =
          I18n.t(
            'workflows.register_notion_verification_token_workflow.errors.missing_webhook',
            environment: Rails.env
          )
        context.fail!(message)
        return
      end

      verification_token = context.verification_token
      if verification_token.blank?
        message =
          I18n.t(
            'workflows.register_notion_verification_token_workflow.errors.missing_token',
            environment: Rails.env
          )
        context.fail!(message)
        return
      end

      webhook.update(verification_token:)
      webhook.start_review
    end
  end
end

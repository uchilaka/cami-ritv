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
        context.fail!(message:)
      end

      if context.success?
        verification_token = context.verification_token
        if verification_token.blank?
          message =
            I18n.t(
              'workflows.register_notion_verification_token_workflow.errors.missing_token',
              environment: Rails.env
            )
          context.fail!(message:)
        end
      end

      if context.failure?
        context.response_http_status = :unprocessable_entity
        return
      end

      webhook.update(verification_token:)
      webhook.start_review
      context.response_http_status = :ok
    end
  end
end

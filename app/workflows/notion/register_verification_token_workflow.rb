# frozen_string_literal: true

module Notion
  # This workflow is responsible for registering a verification token.
  # It is used to verify the connection between Notion and the application.
  class RegisterVerificationTokenWorkflow
    include Interactor

    def call
      # Logic to register the verification token goes here.
      # This could involve saving the token to a database or sending it to an external service.
    end
  end
end

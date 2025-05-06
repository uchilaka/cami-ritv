# frozen_string_literal: true

class UpdateAccountWorkflow
  include Interactor

  # TODO: Include asserting the authorized account
  #   via Current.user
  # (params:, current_user:, account_params:, profile_params:)
  def call
    account = context.account
    context.fail!(messages: ['an account must be provided']) if account.blank?
    context.fail!(messages: ['account update parameters are required']) if context.account_params.blank?
    return unless context.success?

    update_params =
      context
        .account_params
        .to_h.symbolize_keys
        .slice(*self.class.allowed_parameter_keys)
    context.fail!(messages: ['No valid account update parameters found']) unless update_params.present?
    return unless context.success?

    account.assign_attributes(update_params)
    # Ensure metadata is initialized
    account.metadata ||= {}

    # Attempt to process the account phone number
    input_number = update_params.delete(:phone)
    if input_number.present?
      phone_number = PhoneNumber.new(value: input_number)
      if phone_number.valid?
        account.phone = phone_number.serializable_hash
      else
        account.errors.add(:phone, 'is invalid')
        context.fail!(messages: phone_number.errors.full_messages)
      end
    end

    return unless context.success?

    # Capture profile parameters
    profile_params =
      context.profile_params.to_h.symbolize_keys
    # Save profile params to metadata
    account.metadata = account.metadata.merge(profile_params) \
      if profile_params.present?

    account.save
    context.fail!(messages: account.errors.full_messages) if account.errors.any?
  ensure
    context.account = account
  end

  class << self
    def allowed_parameter_keys
      CreateAccountWorkflow.allowed_parameter_keys - %i[email slug]
    end
  end
end

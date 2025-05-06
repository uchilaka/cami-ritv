# frozen_string_literal: true

class CreateAccountWorkflow
  include Interactor

  # TODO: Include asserting the authorized account
  #   via Current.user
  # (params:, current_user:, account_params:, profile_params:)
  def call
    # Support some initialization of the account happening outside of the workflow
    account = context.account
    # Ensure that we have an initialized account record
    account ||= Account.new
    # Calculate the source parameters
    source_params =
      if context.account_params.present?
        context.account_params
      elsif context.params.present?
        context.params
      end
    context.fail!(messages: ['No account create parameters found']) unless source_params.present?
    return unless context.success?

    create_params =
      source_params
        .to_h.symbolize_keys
        .slice(*self.class.allowed_parameter_keys)
    context.fail!(messages: ['No valid account create parameters found']) unless create_params.present?
    return unless context.success?

    # Assign the create params to the account
    account.assign_attributes(create_params)
    # Ensure that we have metadata initialized
    account.metadata ||= {}

    # Attempt to process the account phone number
    input_number = create_params.delete(:phone)
    if input_number.present?
      phone_number = PhoneNumber.new(value: input_number, resource: account, resource_attribute_name: :phone)
      phone_number.load
      if phone_number.errors.any?
        account.errors.add(:phone, 'is invalid')
        context.fail!(messages: phone_number.errors.full_messages)
      end
    end

    return unless context.success?

    # Calculate profile params. This is a bit of a mess and should be refactored.
    source_profile_params =
      if context.profile_params.present?
        context.profile_params
      elsif context.params.present?
        context.params.to_h.symbolize_keys.slice(*business_profile_param_keys)
      end
    profile_params = source_profile_params.to_h.symbolize_keys
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
      %i[display_name status email slug tax_id phone metadata readme type]
    end
  end
end

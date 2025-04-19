# frozen_string_literal: true

module LarCity
  module ProfileParameterUtils
    extend ActiveSupport::Concern

    # @deprecated Use the CreateAccountWorkflow, UpdateAccountWorkflow or UpdateUserProfileWorkflow interceptors instead
    def compose_create_params(request_params)
      raise ArgumentError, 'request_params must be a Hash' \
        unless supported_input?(request_params)

      request_params
        .except(*(common_profile_param_keys + individual_profile_param_keys)).to_h.symbolize_keys
    end

    def supported_input?(params)
      return true if params.is_a?(ActionController::Parameters)
      return true if params.is_a?(Hash)

      false
    end

    # @deprecated Use the CreateAccountWorkflow.allowed_parameter_keys class method instead
    def business_profile_param_keys
      common_profile_param_keys - %i[email]
    end

    # @deprecated Use the UpdateUserProfileWorkflow.allowed_parameter_keys class method instead
    def individual_profile_param_keys
      common_profile_param_keys + %i[image_url family_name given_name]
    end

    # @deprecated Use one of the CreateAccountWorkflow.allowed_parameter_keys,
    #   UpdateUserProfileWorkflow.allowed_parameter_keys or
    #   UpdateUserProfileWorkflow.allowed_parameter_keys class methods instead
    def common_profile_param_keys
      %i[phone email country_alpha2]
    end
  end
end

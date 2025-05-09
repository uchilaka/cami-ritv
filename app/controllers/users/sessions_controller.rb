# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    def create
      # rubocop:disable Style/SymbolProc
      super do |resource|
        # # Set the user's locale to the locale of the last invoice
        # locale = resource&.last_invoice&.locale
        # I18n.locale = locale if locale.present?
        resource.maybe_assign_default_role
      end
      # rubocop:enable Style/SymbolProc
    end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end

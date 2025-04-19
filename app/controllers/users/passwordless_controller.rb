# frozen_string_literal: true

# require_relative '../../../lib/lar_city/signed_global_id_tokenizer'

module Users
  class PasswordlessController < Devise::Passwordless::SessionsController
    # layout 'legacy-application'

    skip_before_action :authenticate_user!, only: %i[new create]
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

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

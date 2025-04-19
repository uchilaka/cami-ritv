# frozen_string_literal: true

module Users
  module Omniauth
    class CallbacksController < Devise::OmniauthCallbacksController
      skip_before_action :verify_authenticity_token, only: :google
      before_action :set_auth_provider

      def google
        # You need to implement the method below in your model (e.g. app/models/user.rb)
        @user = User.from_omniauth

        if @user.persisted?
          flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
          sign_in_and_redirect @user, event: :authentication
        else
          session['devise.google_data'] = request.env['omniauth.auth'].except('extra') # Removing extra as it can overflow some session stores
          redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
        end
      end

      def failure
        redirect_to new_user_registration_url, alert: failure_message
      end

      private

      def set_auth_provider
        Current.auth_provider = request.env['omniauth.auth']
      end
    end
  end
end

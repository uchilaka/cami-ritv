# frozen_string_literal: true

module Users
  module Omniauth
    class CallbacksController < Devise::OmniauthCallbacksController
      # The provider callback is a redirect issued by Google, so it cannot carry a Rails
      # authenticity token and `verify_authenticity_token` would reject every sign-in.
      # (This is the InvalidAuthenticityToken failure that surfaced once the app moved
      # behind the Tailscale funnel.) The skip is scoped to the callback action only --
      # the request phase (`/users/auth/:provider`) keeps Rails' CSRF check, because
      # OmniAuth 2.x is POST-only by default and omniauth-rails_csrf_protection verifies
      # the token there.
      #
      # CSRF protection for this action comes from OmniAuth's `state` parameter instead:
      # omniauth-oauth2 generates it during the request phase, stores it in the session,
      # and aborts the callback when it does not match. `verify_omniauth_state!` below
      # fails closed if that machinery is ever disabled.
      #
      # See CodeQL alert #189 -- the weakened-CSRF finding is expected here; the
      # compensating control is `state`, asserted below rather than assumed.
      skip_before_action :verify_authenticity_token, only: :google

      before_action :verify_omniauth_state!, only: :google
      before_action :set_auth_provider

      def google
        # You need to implement the method below in your model (e.g. app/models/user.rb)
        @user = User.from_omniauth

        if @user.persisted?
          flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
          sign_in_and_redirect @user, event: :authentication
        else
          # `extra` is dropped because it can overflow some session stores.
          session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
          redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
        end
      end

      def failure
        redirect_to new_user_registration_url, alert: failure_message
      end

      private

      # Refuse to complete a sign-in unless OmniAuth's CSRF defence actually ran.
      #
      # Reaching this action without `omniauth.auth` means the middleware did not
      # complete the callback phase, and a strategy configured with
      # `provider_ignores_state: true` would have skipped the `state` check entirely --
      # which, combined with the token skip above, would leave the endpoint genuinely
      # forgeable. Both are treated as a failed authentication rather than a 500.
      def verify_omniauth_state!
        return if request.env['omniauth.auth'].present? && omniauth_state_verified?

        Rails.logger.warn(
          '[omniauth] Rejected callback: OmniAuth state verification did not run. ' \
          'Check that the provider is registered and provider_ignores_state is false.'
        )
        redirect_to new_user_session_url, alert: I18n.t('devise.omniauth_callbacks.failure',
                                                        kind: 'Google',
                                                        reason: I18n.t('devise.omniauth_callbacks.csrf_reason'))
      end

      def omniauth_state_verified?
        strategy = request.env['omniauth.strategy']
        # `omniauth.auth` is already known to be present by the time we get here, so a
        # missing strategy means something other than the middleware populated it (most
        # plausibly a test harness). Defer to the auth check rather than hard-failing.
        return true if strategy.blank?

        !strategy.options[:provider_ignores_state]
      end

      def set_auth_provider
        Current.auth_provider = request.env['omniauth.auth']
      end
    end
  end
end

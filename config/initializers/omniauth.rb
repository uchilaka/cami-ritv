# frozen_string_literal: true

return unless AppUtils.omniauth_enabled?

Rails.application.config.middleware.use OmniAuth::Builder do
  # Accessible at /auth/google
  provider :google_oauth2,
           ENV.fetch('OMNIAUTH_GOOGLE_CLIENT_ID', Rails.application.credentials.google.client_id),
           ENV.fetch('OMNIAUTH_GOOGLE_CLIENT_SECRET', Rails.application.credentials.google.client_secret),
           prompt: 'select_account',
           image_aspect_ratio: 'square',
           name: :google,
           access_type: 'offline'
end

OmniAuth.config.allowed_request_methods = %i[get post]

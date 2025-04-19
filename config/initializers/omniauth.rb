# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  # Accessible at /auth/google
  provider :google_oauth2,
           Rails.application.credentials.google.client_id,
           Rails.application.credentials.google.client_secret,
           prompt: 'select_account',
           image_aspect_ratio: 'square',
           name: :google,
           access_type: 'offline'
end

OmniAuth.config.allowed_request_methods = %i[get]

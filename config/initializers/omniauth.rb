# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  google_client_id = ENV.fetch('GOOGLE_CLIENT_ID', nil) || Rails.application.credentials.dig(:google, :client_id)
  google_client_secret = ENV.fetch('GOOGLE_CLIENT_SECRET', nil) || Rails.application.credentials.dig(:google, :client_secret)

  if google_client_id.present? && google_client_secret.present?
    provider :google_oauth2,
             google_client_id,
             google_client_secret,
             prompt: 'select_account',
             image_aspect_ratio: 'square',
             name: :google,
             access_type: 'offline'
  end
end

OmniAuth.config.allowed_request_methods = %i[get]

# frozen_string_literal: true

required_env_vars =
  %w[
    PORT
    RAILS_ENV
    REDIS_URL
    APP_DATABASE_HOST
    APP_DATABASE_NAME
    APP_DATABASE_PORT
    APP_DATABASE_USER
    APP_DATABASE_PASSWORD
  ]
unless Rails.env.test?
  required_env_vars += %w[
    HOSTNAME
    PAYPAL_BASE_URL
    PAYPAL_CLIENT_ID
    PAYPAL_CLIENT_SECRET
    ZOHO_CLIENT_ID
    ZOHO_CLIENT_SECRET
    CRM_ORG_ID
  ]
end

# Doc on required keys: https://github.com/bkeepers/dotenv?tab=readme-ov-file#required-keys
Dotenv.require_keys(required_env_vars)

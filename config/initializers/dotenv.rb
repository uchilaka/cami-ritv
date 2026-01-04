# frozen_string_literal: true

production_env_vars = %w[
  APP_DATABASE_NAME
  APP_DATABASE_HOST
  APP_DATABASE_PORT
]

required_env_vars =
  %w[
    PORT
    RAILS_ENV
    REDIS_URL
    APP_DATABASE_USER
    APP_DATABASE_PASSWORD
  ]
unless Rails.env.test?
  case Rails.env
  when 'production'
    required_env_vars += production_env_vars
  else
    # Assumes development
    required_env_vars += %w[CRM_SERVICE_PORT]
  end

  # These apply for all non-test environments
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

# frozen_string_literal: true

production_env_vars = %w[
  APP_DATABASE_NAME
  APP_DATABASE_HOST
  APP_DATABASE_PORT
]

# TODO: Taking REDIS_URL out for now, since we're running jobs against a postgres
#   co-located database instance. Revisit this later.
required_env_vars =
  %w[
    PORT
    RAILS_ENV
    APP_DATABASE_USER
    APP_DATABASE_PASSWORD
  ]
unless Rails.env.test?
  required_env_vars += production_env_vars if Rails.env.production?
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

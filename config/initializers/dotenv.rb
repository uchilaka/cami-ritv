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

# Will require the resolved variables within this guard when Rails.env != test
unless Rails.env.test?
  case Rails.env
  when 'development'
    required_env_vars += [
      # Random generated secret for Twenty CRM in development environment
      'APP_SECRET',
      # Service port for Twenty CRM in development environment
      'CRM_SERVICE_PORT',
      'CRM_REDIS_URL',
      'CRM_DATABASE_NAME',
      # The internal local development URL for accessing the Twenty CRM app/admin
      'SERVER_URL',
      # The public-accessible proxy URL for accessing the Twenty CRM app/admin
      'PUBLIC_DOMAIN_URL'
    ]
  else
    # Assumes production-like environment
    required_env_vars += production_env_vars
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

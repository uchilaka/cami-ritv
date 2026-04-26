# frozen_string_literal: true

production_env_vars = []
if AppUtils.database_url_present?
  puts <<~MSG
    ⚠️ DATABASE_URL environment variable detected. Skipping individual
    database configuration checks.
  MSG
else
  {
    'APP_DATABASE_NAME_PRIMARY' => :database,
    'APP_DATABASE_HOST' => :host,
    'APP_DATABASE_PORT' => :port,
  }.each do |var, config_key|
    production_env_vars << var \
      if Rails.application.credentials.dig(:postgres, config_key).blank?
  end
end

# Build required environment variables based on available configurations

# TODO: Taking REDIS_URL out for now, since we're running jobs against a postgres
#   co-located database instance. Revisit this later.
required_env_vars = %w[PORT RAILS_ENV REDIS_URL]

unless AppUtils.database_url_present?
  {
    'APP_DATABASE_USER' => :user,
    'APP_DATABASE_PASSWORD' => :password,
  }.each do |var, config_key|
    required_env_vars << var \
      if Rails.application.credentials.dig(:postgres, config_key).blank?
  end
end

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

  {
    'PAYPAL_API_BASE_URL' => :base_url,
    'PAYPAL_BASE_URL' => :base_url,
    'PAYPAL_CLIENT_ID' => :client_id,
    'PAYPAL_CLIENT_SECRET' => :client_secret,
  }.each do |var, config_key|
    required_env_vars << var \
      if Rails.application.credentials.dig(:paypal, config_key).blank?
  end

  # These apply for all non-test environments
  required_env_vars += %w[HOSTNAME]

  # ZOHO CRM Credentials
  {
    'ZOHO_CLIENT_ID' => :client_id,
    'ZOHO_CLIENT_SECRET' => :client_secret,
    'CRM_ORG_ID' => :org_id,
  }.each do |var, config_key|
    required_env_vars << var \
      if Rails.application.credentials.dig(:zoho, config_key).blank?
  end
end

if AppUtils.check_env_vars?
  puts ['🛠️ Configuring required', Rails.env, 'environment variables'].compact.join(' ')
  # Doc on required keys: https://github.com/bkeepers/dotenv?tab=readme-ov-file#required-keys
  Dotenv.require_keys(required_env_vars)
else
  puts <<~MSG
    ⚠️ Skipping environment variable check in #{Rails.env} environment.
    To enable, set the APP_CONFIG_CHECK_ENV_VARS environment variable to "true".
    The following environment variables are required for this environment:
    #{required_env_vars.join("\n- ")}
  MSG
end

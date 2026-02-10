# frozen_string_literal: true

production_env_vars = []
{
  'APP_DATABASE_NAME' => :database,
  'APP_DATABASE_HOST' => :host,
  'APP_DATABASE_PORT' => :port,
}.each do |var, config_key|
  production_env_vars << var \
    if Rails.application.credentials.dig(:postgres, config_key).blank?
end

# Build required environment variables based on available configurations

# TODO: Taking REDIS_URL out for now, since we're running jobs against a postgres
#   co-located database instance. Revisit this later.
required_env_vars = %w[PORT RAILS_ENV]

{
  'APP_DATABASE_USER' => :user,
  'APP_DATABASE_PASSWORD' => :password,
}.each do |var, config_key|
  required_env_vars << var \
    if Rails.application.credentials.dig(:postgres, config_key).blank?
end

unless Rails.env.test?
  required_env_vars += production_env_vars if Rails.env.production?
  {
    'PAYPAL_API_BASE_URL' => :base_url,
    'PAYPAL_BASE_URL' => :base_url,
    'PAYPAL_CLIENT_ID' => :client_id,
    'PAYPAL_CLIENT_SECRET' => :client_secret,
  }.each do |var, config_key|
    required_env_vars << var \
      if Rails.application.credentials.dig(:paypal, config_key).blank?
  end

  {
    'ZOHO_CLIENT_ID' => :client_id,
    'ZOHO_CLIENT_SECRET' => :client_secret,
    'CRM_ORG_ID' => :org_id,
  }.each do |var, config_key|
    required_env_vars << var \
      if Rails.application.credentials.dig(:zoho, config_key).blank?
  end
end

# Doc on required keys: https://github.com/bkeepers/dotenv?tab=readme-ov-file#required-keys
Dotenv.require_keys(required_env_vars)

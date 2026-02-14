# frozen_string_literal: true

production_env_vars = []
{
  'APP_DATABASE_NAME' => :database,
  'APP_DATABASE_HOST' => :host,
  'APP_DATABASE_PORT' => :port,
}.each do |var, config_key|
  cred_value = begin
    Rails.application.credentials.dig(:postgres, config_key)
  rescue
    nil
  end
  production_env_vars << var if cred_value.blank?
end

required_env_vars = %w[PORT RAILS_ENV]

{
  'APP_DATABASE_USER' => :user,
  'APP_DATABASE_PASSWORD' => :password,
}.each do |var, config_key|
  cred_value = begin
    Rails.application.credentials.dig(:postgres, config_key)
  rescue
    nil
  end
  required_env_vars << var if cred_value.blank?
end

unless Rails.env.test?
  required_env_vars += production_env_vars if Rails.env.production?
  {
    'PAYPAL_API_BASE_URL' => :base_url,
    'PAYPAL_BASE_URL' => :base_url,
    'PAYPAL_CLIENT_ID' => :client_id,
    'PAYPAL_CLIENT_SECRET' => :client_secret,
  }.each do |var, config_key|
    cred_value = begin
      Rails.application.credentials.dig(:paypal, config_key)
    rescue
      nil
    end
    required_env_vars << var if cred_value.blank?
  end

  {
    'ZOHO_CLIENT_ID' => :client_id,
    'ZOHO_CLIENT_SECRET' => :client_secret,
    'CRM_ORG_ID' => :org_id,
  }.each do |var, config_key|
    cred_value = begin
      Rails.application.credentials.dig(:zoho, config_key)
    rescue
      nil
    end
    required_env_vars << var if cred_value.blank?
  end
end

Dotenv.require_keys(required_env_vars)

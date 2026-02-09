# frozen_string_literal: true

if Rails.env.test?
  puts 'Skipping Brevo (Sendinblue) API initialization in test environment.'
  return
end

if AppUtils.send_emails?
  require 'sib-api-v3-sdk'

  SibApiV3Sdk.configure do |config|
    config.api_key['api-key'] = ENV.fetch('BREVO_V3_API_KEY', Rails.application.credentials.brevo&.v3_api_key)
  end
end

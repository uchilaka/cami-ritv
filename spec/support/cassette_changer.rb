# frozen_string_literal: true

require 'vcr'

# @deprecated Use the cassette configurations from config/vcr.yml and :with_paypal_api_credentials
#   to safely (with credential config fallback) load the PayPal API credentials configured for the environment
def maybe_record_cassette(name:, tag: nil, record: :once, &block)
  # VCR cassette API docs: https://rubydoc.info/gems/vcr/6.2.0/VCR#use_cassette-instance_method
  # Community setup guide: https://shopify.engineering/how-to-program-your-vcr
  # TODO: Support multiple tags
  VCR.eject_cassette(name) if VCR.current_cassette&.name == name
  match_requests_on = %i[host uri method]
  exclusive = false

  case name
  when %r{paypal(.com)?/?}
    client_id = ENV.fetch('PAYPAL_CLIENT_ID', nil)
    client_secret = ENV.fetch('PAYPAL_CLIENT_SECRET', nil)

    # Load the cassette in recorder mode if paypal client credentials
    #   are configured in the dev environment
    if client_id.present? && client_secret.present?
      VCR.use_cassette(name, match_requests_on:, exclusive:, record: :new_episodes, tag: :obfuscate) do |_cassette|
        with_paypal_api_credentials { yield block }
      end
    else
      # Load the cassette in read-only mode, requiring paypal (test) credentials
      #   in the credentials secrets file and (already set up) cassette fixture data
      VCR.use_cassette(name, match_requests_on:, exclusive:, record:, tag:, allow_playback_repeats: true) do
        with_paypal_api_credentials { yield block }
      end
    end
  else
    VCR.use_cassette(name, match_requests_on:, exclusive:, record:, tag:) do
      yield block
    end
  end
end

def with_paypal_api_credentials(&block)
  with_modified_env(
    PAYPAL_API_BASE_URL: ENV.fetch('PAYPAL_API_BASE_URL', Rails.application.credentials.paypal.api_base_url),
    PAYPAL_CLIENT_ID: ENV.fetch('PAYPAL_CLIENT_ID', Rails.application.credentials.paypal.client_id),
    PAYPAL_CLIENT_SECRET: ENV.fetch('PAYPAL_CLIENT_SECRET', Rails.application.credentials.paypal.client_secret)
  ) do
    yield block
  end
end

def vcr_cassettes
  Rails.application.config_for(:vcr)[:cassettes]
end

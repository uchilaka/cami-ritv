# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors#rack-configuration
# Read on Devise JWT model configurations here: https://github.com/waiting-for-dev/devise-jwt?tab=readme-ov-file#model-configuration
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Regex test: https://regex101.com/r/oqv0X5/1
    origins "localhost:#{ENV.fetch('PORT')}",
            "127.0.0.1:#{ENV.fetch('PORT')}",
            'https://accounts.larcity.ngrok.dev/',
            %r{\Ahttps?://(?:[a-zA-Z0-9-]+\.)?lar\.city\z}
    resource '/api/*',
             headers: %w[Authorization],
             methods: :any,
             expose: %w[Authorization],
             max_age: Rails.env.production? ? 6.hours.to_i : 15.minutes.to_i
  end
end

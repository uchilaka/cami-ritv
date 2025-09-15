# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { 'cache-control' => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = '/up'

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  # config.cache_store = :mem_cache_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Async jobs are run in the background using SolidQueue.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.active_job.connects_to = { database: { writing: :queue } }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Action Mailer Config
  config.action_mailer.perform_deliveries = AppUtils.send_emails?
  config.action_mailer.delivery_method = :smtp
  # Configure the mailer to use the SMTP server
  config.action_mailer.smtp_settings =
    {
      address: ENV.fetch('SMTP_SERVER', Rails.application.credentials.brevo.smtp_server),
      port: ENV.fetch('SMTP_PORT', Rails.application.credentials.brevo.smtp_port),
      user_name: ENV.fetch('SMTP_USERNAME', Rails.application.credentials.brevo.smtp_user),
      password: ENV.fetch('SMTP_PASSWORD', Rails.application.credentials.brevo.smtp_password),
      enable_starttls_auto: true,
    }
  # Configure logging for the app's mail service.
  config.action_mailer.logger = Rails.logger

  config.action_mailer.default_url_options = { host: 'accounts.staging.larcity.tech' }

  # Print deprecation notices to the Rails logger.
  # config.active_support.deprecation = :log

  # Highlight code that triggered database queries in logs.
  # config.active_record.verbose_query_logs = false

  # Append comments with runtime information tags to SQL queries in logs.
  # config.active_record.query_log_tags_enabled = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # TODO: Disable basic auth for mission_control - to do this, confirm that
  #   in production, the route configured constraints for /admin/mission_control
  #   are working as intended to guard /admin/* routes.
  config.mission_control.jobs.http_basic_auth_enabled = true
end

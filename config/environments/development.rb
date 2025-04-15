require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.
  config.cache_store = :memory_store

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_deliveries = AppUtils.mailhog_enabled? || AppUtils.letter_opener_enabled?
  config.action_mailer.delivery_method =
    if AppUtils.letter_opener_enabled?
      :letter_opener
    else
      :smtp
    end

  # IMPORTANT: If you will be using the mailhog service for testing emails locally,
  #   be sure to set LETTER_OPENER_ENABLED=no (it is set to 'yes' by default).
  #   The LetterOpener gem will save emails as files to ./tmp/email/inbox.
  #
  # Configure the mailer to use the SMTP server
  config.action_mailer.smtp_settings =
    if AppUtils.configure_real_smtp?
      {
        address: ENV.fetch('SMTP_SERVER', Rails.application.credentials.brevo.smtp_server),
        port: ENV.fetch('SMTP_PORT', Rails.application.credentials.brevo.smtp_port),
        user_name: ENV.fetch('SMTP_USERNAME', Rails.application.credentials.brevo.smtp_user),
        password: ENV.fetch('SMTP_PASSWORD', Rails.application.credentials.brevo.smtp_password),
        enable_starttls_auto: true
      }
    else
      { address: 'localhost', port: 1025 }
    end

  # Configure logging for the app's mail service.
  config.action_mailer.logger = Rails.logger
  # IMPORTANT: This will affect whether letter_opener can open the email in the browser or not
  # TODO: Spec this config across development, staging and production
  config.action_mailer.default_url_options = VirtualOfficeManager.initial_default_url_options

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true
end

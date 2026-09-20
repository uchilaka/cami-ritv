# frozen_string_literal: true

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!
require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  dotenv_files = %w[.env.test.local .env.test .env].select { |file| File.exist?(file) }
  Dotenv.load(*dotenv_files)

  # Force the test database NAMES, which must never be inherited from a dev shell.
  #
  # .envrc derives APP_DATABASE_NAME_* from NODE_ENV rather than RAILS_ENV, so a shell
  # sitting in "development" exports sails_development even for `RAILS_ENV=test`, and
  # Dotenv.load deliberately does not overwrite already-set variables -- so .env.test.local
  # cannot correct it. spec/rails_helper.rb truncates whatever this resolves to.
  #
  # Only the NAMES are forced. Host, port, user and password are left to the shell so the
  # suite runs against whichever Postgres the developer actually has up; a blanket
  # `Dotenv.load(overwrite: true)` would also impose .env.test.local's compose-oriented
  # host/port/credentials and break local runs against a host Postgres.
  #
  # `overwrite: true` below applies to the PARSE only -- Dotenv.parse never mutates ENV.
  # Without it the parser echoes back the value already in ENV for any key ENV holds
  # (dotenv/parser.rb:59), i.e. the very dev-shell value being corrected here.
  #
  # Parse the SAME chain Dotenv.load just used, at the same precedence (earlier files win),
  # rather than .env.test.local alone -- otherwise a custom *_test name configured in
  # .env.test or .env is ignored in favour of the fallbacks below.
  test_env_values = dotenv_files.reduce({}) do |values, file|
    values.reverse_merge(Dotenv.parse(file, overwrite: true))
  end
  {
    'APP_DATABASE_NAME_PRIMARY' => 'sails_test',
    'APP_DATABASE_NAME_CRM' => 'twenty_crm_test',
  }.each do |var, fallback|
    next if ENV[var].to_s.end_with?('_test')

    ENV[var] = test_env_values[var].presence || fallback
  end

  # https://github.com/heartcombo/devise?tab=readme-ov-file#testing
  config.middleware.insert_before Warden::Manager, ActionDispatch::Cookies
  config.middleware.insert_before Warden::Manager, ActionDispatch::Session::CookieStore

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV['CI'].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { 'cache-control' => 'public, max-age=3600' }

  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Unlike controllers, the mailer instance doesn't have any context about the
  # incoming request so you'll need to provide the :host parameter yourself.
  config.action_mailer.default_url_options = { host: 'accounts.larcity.test', port: ENV.fetch('PORT') }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Disable CSS pre-processing in tests: https://stackoverflow.com/a/78148201/3726759
  config.assets.css_compressor = nil
end

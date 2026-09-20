# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Prevent the suite from operating on a non-test database.
#
# `Rails.env == "test"` does NOT guarantee the *database* is a test database. `.envrc`
# exports APP_DATABASE_NAME_PRIMARY derived from NODE_ENV (not RAILS_ENV), and
# config/database.yml reads that variable, so a value inherited from a development shell
# can win over the one in .env.test.local. The `before(:suite)` hook below runs
# DatabaseCleaner.clean_with(:truncation) gated only on `Rails.env.test?`, so without this
# guard a normal `RAILS_ENV=test bundle exec rspec` would truncate the development database.
db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'primary')
resolved_db = db_config&.database

unless resolved_db.to_s.end_with?('_test')
  abort(<<~MSG)
    \u{1F6AB} Refusing to run the test suite: resolved primary database is '#{resolved_db}',
    which is not a test database (expected a name ending in "_test").

    This usually means APP_DATABASE_NAME_PRIMARY was inherited from your shell
    (direnv/mise load .envrc, which derives it from NODE_ENV). Check with:

        RAILS_ENV=test bundle exec rails runner 'puts ActiveRecord::Base.configurations.configs_for(env_name: "test", name: "primary").database'

    Fix by unsetting the inherited value, or by setting it explicitly:

        APP_DATABASE_NAME_PRIMARY=sails_test bundle exec rspec
  MSG
end
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'aasm/rspec'
require 'pundit/rspec'
require 'shoulda/matchers'
require 'shoulda/matchers/integrations/test_frameworks/rspec'
require 'database_cleaner/active_record'
require 'devise/test/integration_helpers'
require 'vcr'
require 'lib/zoho/credentials'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# VCR usage docs https://benoittgt.github.io/vcr
VCR.configure do |vcr_config|
  vcr_config.cassette_library_dir = 'spec/fixtures/cassettes'
  vcr_config.hook_into :faraday
  # Unrecorded HTTP raises instead of hitting the network.
  #
  # This was `true`, which let any spec without a cassette perform live calls. In practice
  # the Zoho specs did: every example in them issued a real
  # GET https://accounts.zoho.com/oauth/serverinfo, so the suite went red whenever Zoho
  # rate-limited the account and silently required network access in CI.
  #
  # Specs that stub HTTP themselves (rather than via VCR) must opt out explicitly with
  # `VCR.turned_off` -- `hook_into :faraday` inserts VCR middleware into every Faraday
  # connection, including ones built with Faraday's test adapter. Use `stubs_http: true`
  # metadata to apply spec/support/self_stubbed_http.rb's `around` hook.
  vcr_config.allow_http_connections_when_no_cassette = false

  # IMPORTANT: Enables automatic cassette naming based on tags
  vcr_config.configure_rspec_metadata!

  # Filter out Zoho credentials (applies to all examples)
  # vcr_config.filter_sensitive_data('<ZOHO_CLIENT_ID>') { Zoho::Credentials.client_id }
  # vcr_config.filter_sensitive_data('<ZOHO_CLIENT_SECRET>') { Zoho::Credentials.client_secret }

  # Filter out Zoho credentials (applies only to examples tagged with :zoho_cassette)
  vcr_config.define_cassette_placeholder('<ZOHO_CLIENT_ID>', :zoho_cassette) { Zoho::Credentials.client_id }
  vcr_config.define_cassette_placeholder('<ZOHO_CLIENT_SECRET>', :zoho_cassette) { Zoho::Credentials.client_secret }
  vcr_config.define_cassette_placeholder('<ZOHO_AUTHORIZATION_HEADER>', :zoho_cassette) do |interaction|
    interaction.request.headers['Authorization'].try(:first)
  end

  # Setup :before_record hook to intercept PII data and prevent it from leaking into the cassettes
  vcr_config.before_record(:obfuscate) do |interaction, cassette|
    if interaction.response.body.present?
      if cassette.name.present? &&
        interaction.response.headers['content-type'].any? { |t| %r{application/json}.match?(t) }
        # Some housekeeping to prepare for making a dub of the original response
        dub_file = Rails.root.join('spec', 'fixtures', 'pii', "#{cassette.name}.json").to_s
        pii_path = File.dirname(dub_file)
        FileUtils.mkdir_p(pii_path) unless File.directory?(pii_path)
        # Prettify the JSON data for easier reading by humans
        og_response_data = JSON.pretty_generate(JSON.parse(interaction.response.body))
        # Save the original response body to a fixture location that can be
        #  validated but not committed to source control
        File.write(dub_file, og_response_data)
      end
      interaction.response.body = PIISanitizer.sanitize(interaction.response.body)
    end
  end

  vcr_config.before_http_request do |req|
    Rails.logger.info "VCR: Request", { method: req.method, uri: req.uri, headers: req.headers }
  end
end

RSpec.configure do |config|
  config.fail_fast = AppUtils.yes?(ENV.fetch('RSPEC_FAIL_FAST', false)) ? true : false

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-1/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Time testing helpers
  config.include ActiveSupport::Testing::TimeHelpers, time_sensitive: true

  # Devise integration helpers https://github.com/heartcombo/devise?tab=readme-ov-file#integration-tests
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :view

  # Internationalization guide: https://guides.rubyonrails.org/i18n.html
  config.include AbstractController::Translation, type: :view
  config.include AbstractController::Translation, type: :helper

  # Testing Jobs
  config.include ActiveJob::TestHelper, type: :job
  config.include ActiveJob::TestHelper, feature: :invoicing

  # Specs that stub HTTP themselves rather than via a VCR cassette
  config.include_context 'with self-stubbed http', stubs_http: true

  # Sample phone numbers
  config.include_context 'for phone number testing', real_world_data: true

  # Sample invoices
  config.include_context 'for invoice testing', preload_invoice_data: true

  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end
    # Ensure that truncation ONLY happens in rails test environment
    if Rails.env.test?
      DatabaseCleaner.clean_with(:truncation)
    else
      puts "️⚠️ RSpec is running in #{Rails.env} environment. Skipping database truncation. 🙅🏾‍♂️"
    end

    Rails.application.load_seed
  end

  # Review example of RSpec with Capybara configuration:
  # https://github.com/DatabaseCleaner/database_cleaner?tab=readme-ov-file#rspec-with-capybara-example
  config.before(:each) do |example|
    # Database cleaner setup: https://github.com/DatabaseCleaner/database_cleaner?tab=readme-ov-file#rspec-example
    #
    # JS-driven specs need :truncation. The app-under-test that the browser connects to
    # runs in a separate thread with its own database connection, which cannot see data
    # written inside this spec's uncommitted transaction -- the exact situation the
    # `before(:suite)` guard above describes.
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.around(:each) do |example|
    # Conditionally load invoice sample data
    load_sample_invoice_dataset if example.metadata[:preload_invoice_data]

    # Run example
    example.run
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
    # Clean up all test double state
    RSpec::Mocks.teardown
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

# Headless Chrome driven over CDP by Cuprite/Ferrum.
#
# Chosen over selenium-webdriver (which this replaces) because there is no chromedriver
# binary to keep in sync with the installed Chrome version, and over Playwright because
# system specs reuse this suite's fabricators, VCR config and Knapsack sharding rather than
# standing up a second test stack.
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 1400],
    browser_options: {
      # Required when Chrome runs as root in a CI container.
      'no-sandbox' => nil,
      'disable-gpu' => nil,
      # CI runners give containers a small /dev/shm, which crashes Chrome under load.
      'disable-dev-shm-usage' => nil,
    },
    process_timeout: 20,
    timeout: 20,
    headless: true,
    # `INSPECTOR=1 bundle exec rspec spec/system/...` opens a debuggable browser.
    inspector: ENV['INSPECTOR'].present?
  )
end

# Non-JS system specs stay on rack_test: no browser process, much faster. Opt into the
# real browser per example with `js: true`.
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite

# Bind the app-under-test to loopback. The port stays dynamic so concurrent worktrees and
# parallel CI nodes don't collide; pin it if/when the suite runs against a container.
Capybara.server_host = '127.0.0.1'
Capybara.server = :puma, { Silent: true }

Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by(:rack_test) }
  config.before(:each, type: :system, js: true) { driven_by(:cuprite) }

  # Block the browser from reaching the public internet.
  #
  # VCR cannot help here -- it hooks the Ruby HTTP stack, not traffic the browser makes.
  # Fabricated records carry external URLs (Faker::Avatar.image returns a robohash.org
  # link), and Ferrum raises PendingConnectionsError when those hang, so specs would go red
  # on unrelated third-party availability. Allow the app under test and inline resources;
  # abort everything else.
  #
  # This compares parsed origins rather than matching a URL prefix. A prefix check is not
  # an origin check: in `http://127.0.0.1:80@evil.example/`, `127.0.0.1:80` is *userinfo*
  # and the real host is evil.example, so `start_with?('http://127.0.0.1:')` would let it
  # through. The app serves its own built Vite assets in test (config/vite.json sets
  # autoBuild for the test env), so no separate asset origin needs allowing.
  config.before(:each, type: :system, js: true) do
    browser = page.driver.browser
    browser.network.intercept

    browser.on(:request) do |request|
      if SystemSpecNetwork.allowed?(request.url, Capybara.current_session.server)
        request.continue
      else
        request.abort
      end
    end
  end

  # System specs need CSRF protection ON, unlike the rest of the suite.
  #
  # config/environments/test.rb disables forgery protection, which makes `csrf_meta_tags`
  # render nothing. app/frontend/entrypoints/application.tsx *throws* when the csrf-token
  # meta tag is absent, so without this no Inertia page mounts at all under a browser --
  # the React app dies before createInertiaApp runs and you get the bare layout.
  #
  # Enabling it here also matches production more closely than the suite-wide default:
  # the browser submits real forms with real tokens.
  config.around(:each, type: :system) do |example|
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = original
  end
end

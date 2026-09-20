# frozen_string_literal: true

require 'warden'

# Devise's Test::IntegrationHelpers#sign_in manipulates the Rack session of the spec's own
# request, which system specs do not make -- the browser does, in a separate thread, holding
# its own session. Warden's test mode installs a hook on the app-under-test instead, so the
# browser's requests come through authenticated.
Warden.test_mode!

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :system
  config.after(:each, type: :system) { Warden.test_reset! }
end

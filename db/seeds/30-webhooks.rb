# frozen_string_literal: true

require 'lib/commands/lar_city/cli/devkit_cmd'

if Rails.env.test?
  # In test environment, we don't want to run the setup_webhooks command
  # as it may interfere with the test database or cause unnecessary side effects.
  puts 'Skipping webhook setup in test environment.'
  return
end

LarCity::CLI::DevkitCmd
  .new.invoke(:setup_webhooks, [], vendor: 'notion', verbose: Rails.env.development?)

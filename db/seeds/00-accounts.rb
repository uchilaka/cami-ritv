# frozen_string_literal: true

unless Rails.env.development?
  # TODO: Confirm this isn't required by the test suite
  Rails.logger.info('Skipping seed file', env: Rails.env, class: 'Fixtures::Accounts')
  return
end

Fixtures::Accounts.new.invoke(:load, [], verbose: Rails.env.development?)

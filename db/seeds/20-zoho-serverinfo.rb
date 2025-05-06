# frozen_string_literal: true

require 'lib/tasks/fixtures/zoho/serverinfo'

unless Rails.env.development?
  Rails.logger.info('Skipping seed file', env: Rails.env, class: 'Zoho::UpdateServerinfoMetadata')
  return
end

Fixtures::Zoho::Serverinfo.new.invoke(:load, [], verbose: Rails.env.development?)

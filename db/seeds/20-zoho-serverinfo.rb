# frozen_string_literal: true

require 'lib/tasks/fixtures/zoho/serverinfo'

if Rails.env.production?
  Rails.logger.info('Skipping seed file', env: Rails.env, class: 'Zoho::UpdateServerinfoMetadata')
else
  Fixtures::Zoho::Serverinfo.new.invoke(:load, [], verbose: Rails.env.development?)
end

# frozen_string_literal: true

if Rails.env.development?
  Zoho::UpdateServerinfoMetadata.call
else
  Rails.logger.info('Skipping seed file', env: Rails.env, class: 'Zoho::UpdateServerinfoMetadata')
end

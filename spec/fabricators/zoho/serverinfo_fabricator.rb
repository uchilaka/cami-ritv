# frozen_string_literal: true

Fabricator('Zoho::OauthServerinfo') do
  key { 'https://accounts.zoho.com/oauth/serverinfo' }
  value { {} }
end

Fabricator(:zoho_oauth_serverinfo, from: 'Zoho::OauthServerinfo') do
  value do
    {
      region: 'US',
      region_name: 'United States of America',
      endpoint: 'https://accounts.zoho.com',
    }
  end
end

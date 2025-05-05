# frozen_string_literal: true

Fabricator('Zoho::Serverinfo') do
  key { 'https://accounts.zoho.com/oauth/serverinfo' }
  value { {} }
end

Fabricator(:zoho_serverinfo, from: 'Zoho::Serverinfo') do
  value do
    {
      oauth: {
        region: 'US',
        region_name: 'United States of America',
        endpoint: 'https://accounts.zoho.com',
      },
    }
  end
end

# frozen_string_literal: true

# 20250506021526
class AddZohoServerinfoForCrmAuth < ActiveRecord::Migration[8.0]
  def up
    # US region
    us_oauth_serverinfo =
      Zoho::OauthServerinfo.find_or_initialize_by(key: 'https://accounts.zoho.com')
    us_oauth_serverinfo
      .update!(
        value: {
          'endpoint' => 'https://accounts.zoho.com',
          'region_name' => 'United States of America',
          'resource_url' => 'https://accounts.zoho.com/oauth/serverinfo',
          'region_alpha2' => 'US',
        }
      )
    # EU region
    eu_oauth_serverinfo =
      Zoho::OauthServerinfo.find_or_initialize_by(key: 'https://accounts.zoho.eu')
    eu_oauth_serverinfo
      .update!(
        value: {
          'endpoint' => 'https://accounts.zoho.eu',
          'region_name' => 'European Union',
          'resource_url' => 'https://accounts.zoho.eu/oauth/serverinfo',
          'region_alpha2' => 'EU',
        }
      )
    # UK region
    uk_oauth_serverinfo =
      Zoho::OauthServerinfo.find_or_initialize_by(key: 'https://accounts.zoho.eu')
    uk_oauth_serverinfo
      .update!(
        value: {
          'endpoint' => 'https://accounts.zoho.uk',
          'region_name' => 'United Kingdom',
          'resource_url' => 'https://accounts.zoho.eu/oauth/serverinfo',
          'region_alpha2' => 'GB',
        }
      )
    # CA region
    ca_oauth_serverinfo =
      Zoho::OauthServerinfo.find_or_initialize_by(key: 'https://accounts.zoho.com')
    ca_oauth_serverinfo
      .update!(
        value: {
          'endpoint' => 'https://accounts.zohocloud.ca',
          'region_name' => 'Canada',
          'resource_url' => 'https://accounts.zoho.com/oauth/serverinfo',
          'region_alpha2' => 'CA',
        }
      )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

# frozen_string_literal: true

class AddDigitalOceanToVendors < ActiveRecord::Migration[7.2]
  def up
    digital_ocean = Vendor.new(
      slug: 'digital-ocean',
      display_name: 'DigitalOcean',
      metadata: {
        website_url: 'https://digitalocean.com',
        support_url: 'https://www.digitalocean.com/support/',
        status_url: 'https://status.digitalocean.com/',
        billing_url: 'https://cloud.digitalocean.com/account/billing/history?i=a2dea4',
        resources: {
          larcity: {
            name: 'Larcity Labs @ DigitalOcean',
            url: 'https://cloud.digitalocean.com/projects/13e8f7a6-c302-47a9-9044-5fa322ee5458/resources?i=a2dea4',
          },
          storysprout: {
            name: 'StorySprout AI @ DigitalOcean',
            url: 'https://cloud.digitalocean.com/projects/a9db7f41-baee-48cf-9e45-f84e8edf6c87/resources?i=a2dea4',
          }
        },
        services: {
          droplets: {
            name: 'Droplets',
            short_desc: 'Droplets in minutes',
            desc: 'Droplets are Linux-based virtual machines (VMs) that run on top of virtualized hardware. Each Droplet you create is a new server you can use, either standalone or as part of a larger, cloud-based infrastructure.',
            url: 'https://cloud.digitalocean.com/droplets?i=a2dea4&preserveScrollPosition=false',
          },
          functions: {
            name: 'Functions',
            short_desc: 'Runs on Demand. Scales Automatically.',
            desc: 'DigitalOcean Functions is a serverless computing solution that runs on-demand, enabling you to focus on your code, scale instantly with confidence, and save costs by eliminating the need to maintain servers.',
            url: 'https://cloud.digitalocean.com/functions?i=a2dea4'
          }
        }
      }
    )
    digital_ocean.save!
    puts "🪄 Created vendor: #{digital_ocean.display_name} [#{digital_ocean.slug}]" if digital_ocean.persisted?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

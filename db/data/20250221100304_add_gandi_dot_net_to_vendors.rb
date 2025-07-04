# frozen_string_literal: true

class AddGandiDotNetToVendors < ActiveRecord::Migration[7.2]
  def up
    gandi = Vendor.new(
      slug: 'gandi',
      display_name: 'Gandi US, Inc.',
      metadata: {
        website_url: 'https://gandi.net',
        support_url: 'https://helpdesk.gandi.net/hc/en-us/requests',
        status_url: 'https://status.gandi.net/',
        # Vendor-wide billing view
        billing_url: 'https://admin.gandi.net/billing/1f7281e2-9db0-11e7-a7db-00163ec31f40/organizations',
        # TODO: Implement a VendorResource model for records in
        #   <vendor-instance>.dig(:metadata, :resources)
        resources: {
          larcity: {
            name: 'Larcity Project @ Gandi.net',
            url: 'https://admin.gandi.net/dashboard/1f7281e2-9db0-11e7-a7db-00163ec31f40',
            # Resource/Project-specific billing view
            billing_url: 'https://admin.gandi.net/billing/1f7281e2-9db0-11e7-a7db-00163ec31f40/overview',
          }
        },
        services: {
          web_hosting: {
            name: 'Web Hosting',
            url: 'https://admin.gandi.net/simplehosting/1f7281e2-9db0-11e7-a7db-00163ec31f40/instances'
          },
          domain_hosting: {
            name: 'Domain Hosting',
            url: 'https://admin.gandi.net/domain/1f7281e2-9db0-11e7-a7db-00163ec31f40'
          },
          organizations: {
            name: 'Organizations',
            url: 'https://admin.gandi.net/organizations/1f7281e2-9db0-11e7-a7db-00163ec31f40/organizations'
          }
        }
      }
    )
    gandi.save!
    puts "🪄 Created vendor: #{gandi.display_name} [#{gandi.slug}]" if gandi.persisted?
  end

  def down
    Vendor.find_by(slug: 'gandi-dot-net')&.destroy
  end
end

# frozen_string_literal: true

class AddGandiDotNetToVendors < ActiveRecord::Migration[7.2]
  def up
    updates = { display_name: 'Gandi US, Inc.', metadata: }
    gandi = Vendor.find_or_initialize_by(slug: 'gandi-dot-net')
    gandi.assign_attributes(**updates)
    action_taken = gandi.new_record? ? 'create' : 'update'
    gandi.save! if gandi.new_record? || gandi.changed?
    puts "🪄 #{action_taken.capitalize}d vendor: #{gandi.display_name} [#{gandi.slug}]" if gandi.persisted?
  end

  def down
    Vendor.find_by(slug: 'gandi-dot-net')&.destroy
  end

  private

  def metadata
    {
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
        },
      },
      services: {
        web_hosting: {
          name: 'Web Hosting',
          url: 'https://admin.gandi.net/simplehosting/1f7281e2-9db0-11e7-a7db-00163ec31f40/instances',
        },
        domain_hosting: {
          name: 'Domain Hosting',
          url: 'https://admin.gandi.net/domain/1f7281e2-9db0-11e7-a7db-00163ec31f40',
        },
        organizations: {
          name: 'Organizations',
          url: 'https://admin.gandi.net/organizations/1f7281e2-9db0-11e7-a7db-00163ec31f40/organizations',
        },
      },
    }
  end
end

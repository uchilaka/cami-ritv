# frozen_string_literal: true

require 'awesome_print'

# 20250221093342
class AddKnapsackProToVendors < ActiveRecord::Migration[7.2]
  def up
    knapsack_pro = Vendor.new(
      slug: 'knapsack-pro',
      display_name: 'Knapsack Pro',
      metadata: {
        website_url: 'https://knapsackpro.com',
        support_url: 'https://knapsackpro.com/contact',
        billing_url: 'https://knapsackpro.com/dashboard/billing',
        # TODO: Implement a VendorResource model for records in
        #   <vendor-instance>.dig(:metadata, :resources)
        resources: {
          cami: {
            name: 'CAMI Project @ Knapsack Pro',
            url: 'https://knapsackpro.com/dashboard/organizations/4019/projects/2608',
          },
        },
      }
    )
    knapsack_pro.save!
    puts "🪄 Created vendor: #{knapsack_pro.display_name} [#{knapsack_pro.slug}]" if knapsack_pro.persisted?
    # if knapsack_pro.persisted?
    #   puts "🪄 Created vendor: #{knapsack_pro.display_name} [#{knapsack_pro.slug}]"
    # else
    #   puts "❌ Failed to create vendor: #{knapsack_pro.display_name} [#{knapsack_pro.slug}]"
    #   ap knapsack_pro.errors.full_messages if knapsack_pro.errors.any?
    # end
  end

  def down
    Vendor.find_by(slug: 'knapsack-pro')&.destroy
  end
end

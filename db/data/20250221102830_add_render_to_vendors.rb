# frozen_string_literal: true

class AddRenderToVendors < ActiveRecord::Migration[7.2]
  def up
    render = Vendor.new(
      slug: 'render',
      display_name: 'Render',
      metadata: {
        website_url: 'https://render.com',
        pricing_url: 'https://render.com/pricing'
      },
      readme: <<~README
        # Render
        > Your fastest path to production

        ## Hero Value Proposition
        Build, deploy, and scale your apps with unparalleled ease – from your first user to your billionth.
      README
    )
    render.save!
    puts "🪄 Created vendor: #{render.display_name} [#{render.slug}]" if render.persisted?
  end

  def down
    Vendor.find_by(slug: 'render')&.destroy
  end
end

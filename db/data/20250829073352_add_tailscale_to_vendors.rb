# frozen_string_literal: true

# 20250829073352
class AddTailscaleToVendors < ActiveRecord::Migration[8.0]
  def up
    tailscale =
      Vendor.new(
        display_name: 'Tailscale',
        slug: 'tailscale',
        metadata: {
          about_url: 'https://tailscale.com/why-tailscale',
          quickstart_url: 'https://tailscale.com/kb/1017/install',
          pricing_url: 'https://tailscale.com/pricing?plan=business',
          status_url: 'https://status.tailscale.com/',
          support_url: 'https://tailscale.com/contact/support',
          website_url: 'https://tailscale.com',
        },
        readme: <<~README
          # Tailscale
          Fast, seamless device connectivity — no hardware, no firewall rules,
          no wasted time.

          ## Discovery story
          I first heard about Tailscale when looking into more price-competitive
          alternatives for NGROK. A cheekily worded Google search targeted ad led
          me to Tailscale's website, and I was intrigued by the set of features for
          their free tier, as well as their value proposition to developers and
          small teams.
        README
      )
    tailscale.save!
    puts "🪄 Created vendor: #{tailscale.display_name} [#{tailscale.slug}]" if tailscale.persisted?
  end

  def down
    Vendor.find_by(slug: 'tailscale')&.destroy
  end
end

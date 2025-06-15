# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  data               :jsonb
#  slug               :string
#  status             :string           default("pending_review"), not null
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_webhooks_on_slug    (slug) UNIQUE
#  index_webhooks_on_status  (status)
#
Fabricator(:webhook) do
  transient :integration
  slug               do |attrs|
    if attrs[:integration] == :notion
      :notion
    else
      sequence(:slug) { |i| "webhook-#{i}" }
    end
  end
  verification_token { SecureRandom.alphanumeric(24) }
end

Fabricator(:notion_webhook, from: :webhook) do
  slug               { 'notion' }
  data               { { integration_id: SecureRandom.uuid, integration_name: 'Notion Integration' } }
end

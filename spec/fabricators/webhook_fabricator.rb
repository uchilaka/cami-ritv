# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  data               :jsonb
#  slug               :string
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_webhooks_on_slug  (slug) UNIQUE
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

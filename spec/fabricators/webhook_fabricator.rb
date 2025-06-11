# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  url                :string
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
Fabricator(:webhook) do
  url                { sequence(:url) { |i| Faker::Internet.url(host: "app.vendor-#{i}.dev") } }
  verification_token { SecureRandom.alphanumeric(24) }
end

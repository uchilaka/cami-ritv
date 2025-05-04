# frozen_string_literal: true

# == Schema Information
#
# Table name: identity_provider_profiles
#
#  id           :uuid             not null, primary key
#  display_name :string
#  email        :string
#  family_name  :string           default("")
#  given_name   :string           default("")
#  image_url    :string
#  metadata     :jsonb
#  provider     :string
#  uid          :string
#  verified     :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_identity_provider_profiles_on_email_and_provider    (email,provider) UNIQUE
#  index_identity_provider_profiles_on_uid_and_provider      (uid,provider) UNIQUE
#  index_identity_provider_profiles_on_user_id               (user_id)
#  index_identity_provider_profiles_on_user_id_and_provider  (user_id,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
Fabricator(:identity_provider_profile) do
  uid                  { SecureRandom.alphanumeric(21) }
  # user                 { Fabricate(:user) }
  provider             'whatsapp'
  verified              false
  email                { Faker::Internet.email }
  given_name           { Faker::Name.neutral_first_name }
  family_name          { Faker::Name.last_name }
  display_name         { |attrs| "#{attrs[:given_name]} #{attrs[:family_name]}".strip }
  metadata             do |attrs|
    {
      unverified_email: attrs[:email],
      email_verified: false,
      confirmed_at: nil
    }.merge(attrs[:metadata] || {})
  end
end

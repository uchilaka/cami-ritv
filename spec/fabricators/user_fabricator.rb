# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  family_name            :string
#  given_name             :string
#  last_request_at        :datetime
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  profile                :jsonb
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  timeout_in             :integer          default(1800)
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
Fabricator(:user) do
  transient :phone_number

  email         { Faker::Internet.email }
  given_name    { Faker::Name.gender_neutral_first_name }
  family_name   { Faker::Name.last_name }
  password      { Faker::Internet.password(min_length: 8) }
  profile        do |attrs|
    phone_number = Phonelib.parse(attrs[:phone_number] || Faker::PhoneNumber.cell_phone)
    {
      image_url: Faker::Avatar.image,
      phone_e164: phone_number.e164,
      phone_country: phone_number.country
    }
  end
end

Fabricator(:user_with_provider_profiles, from: :user) do
  providers   { %w[google apple whatsapp] }
  uids        do
    {
      'google' => SecureRandom.alphanumeric(21),
      'apple' => SecureRandom.alphanumeric(21),
      'whatsapp' => SecureRandom.alphanumeric(21)
    }
  end

  after_create do |user|
    user.providers.each do |provider|
      user.uids[provider] ||= SecureRandom.alphanumeric(21)
      Fabricate(:identity_provider_profile, uid: user.uids[provider], user:, provider:)
    end
    user.save!
  end
end

Fabricator(:admin, from: :user) do
  after_create do |user|
    user.add_role(:admin)
  end
end

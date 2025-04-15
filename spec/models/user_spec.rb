# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  family_name            :string
#  given_name             :string
#  last_request_at        :datetime
#  locked_at              :datetime
#  nickname               :string
#  profile                :jsonb
#  providers              :string           default([]), is an Array
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  timeout_in             :integer          default(1800)
#  uids                   :jsonb
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
#
require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:email) { Faker::Internet.email }

  # around do |example|
  #   Sidekiq::Testing.inline! { example.run }
  # end

  subject { Fabricate :user }

  it { should validate_presence_of :email }
  it { should validate_uniqueness_of(:email).case_insensitive }
  xit { should have_many(:identity_provider_profiles).dependent(:destroy) }
  xit { should have_and_belong_to_many(:accounts).inverse_of(:members) }
  xit { should have_and_belong_to_many(:roles).join_table('users_roles') }
  xit { should have_many(:invoices) }

  describe 'callbacks', skip: "this feature isn't available yet" do
    describe ':after_destroy_commit' do
      subject do
        Fabricate(:user_with_provider_profiles, email:, providers: %w[google whatsapp])
      end

      it 'destroys any identity provider profiles' do
        expect(subject.identity_provider_profiles.size).to be(2)
        expect { subject.destroy }.to change { IdentityProviderProfile.count }.by(-2)
      end
    end
  end

  describe '#profile' do
    context 'with phone number' do
      let(:phone_number) { Faker::PhoneNumber.cell_phone }

      subject { Fabricate(:user, email:, phone_number:) }

      it 'supports saving the phone number' do
        parsed_phone_number = Phonelib.parse(phone_number)
        expect(subject.profile['phone_e164']).to eq(parsed_phone_number.full_e164)
      end
    end
  end

  describe '#admin?', skip: "this feature isn't available yet" do
    subject { Fabricate(:user, email:) }

    context 'when the user has the admin role' do
      before { subject.add_role(:admin) }

      it 'returns true' do
        expect(subject.admin?).to be(true)
      end
    end

    context 'when the user does not have the admin role' do
      it 'returns false' do
        expect(subject.admin?).to be(false)
      end
    end
  end
end

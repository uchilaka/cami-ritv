# frozen_string_literal: true

require 'rails_helper'

load 'lib/tasks/fixtures/users.thor'

RSpec.describe Fixtures::Users do
  let(:fixtures) do
    [
      {
        email: Faker::Internet.email,
        family_name: Faker::Name.last_name,
        given_name: Faker::Name.gender_neutral_first_name,
        profile: {
          image_url: Faker::Avatar.image
        },
        providers: %w[google facebook whatsapp],
        roles: %w[admin user],
        uids: {
          google: SecureRandom.random_number(1_000_000_000),
          facebook: SecureRandom.random_number(1_000_000_000),
          whatsapp: SecureRandom.random_number(1_000_000_000)
        }
      },
      {
        email: Faker::Internet.email,
        family_name: Faker::Name.last_name,
        given_name: Faker::Name.gender_neutral_first_name,
        profile: {
          image_url: Faker::Avatar.image
        },
        providers: %w[whatsapp],
        roles: %w[],
        uids: {
          whatsapp: SecureRandom.random_number(1_000_000_000)
        }
      },
      {
        email: Faker::Internet.email,
        family_name: Faker::Name.last_name,
        given_name: Faker::Name.gender_neutral_first_name,
        profile: {
          image_url: Faker::Avatar.image
        }
      },
      {
        email: Faker::Internet.email,
        family_name: Faker::Name.last_name,
        given_name: Faker::Name.gender_neutral_first_name,
        roles: []
      },
    ].map(&:stringify_keys)
  end

  before do
    allow(YAML).to receive(:load).and_return(fixtures)
  end

  describe '#load' do
    subject { described_class.new.invoke(:load, []) }

    it 'loads the fixtures' do
      expect { subject }.to change(User, :count).by(4)
    end

    context 'when the fixtures have already been loaded' do
      before { Fabricate(:user, email: fixtures.first['email']) }

      it 'loads only the new fixtures' do
        expect { subject }.to change(User, :count).by(3)
      end
    end
  end
end

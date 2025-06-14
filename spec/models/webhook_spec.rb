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
require 'rails_helper'

RSpec.describe Webhook, type: :model do
  subject(:webhook) { Fabricate(:webhook, verification_token:) }

  let(:verification_token) { 'secret-token' }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to have_rich_text(:readme) }
    it { is_expected.to have_many(:generic_events).dependent(:nullify) }

    context 'with several vendor events' do
      before do
        Fabricate(:deal_created_event, integration: :notion, eventable: webhook)
        Fabricate(:deal_created_event, integration: :notion, eventable: webhook)
        Fabricate(:deal_created_event, integration: :notion, eventable: webhook)
      end

      it { expect(webhook.generic_events).to have_attributes(size: 3) }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_length_of(:slug).is_at_most(64) }
    it { is_expected.to validate_presence_of(:verification_token) }
  end

  describe 'friendly_id' do
    it 'uses the slug as the friendly id' do
      expect(Webhook.friendly).to eq(Webhook)
      expect(webhook.to_param).to eq(webhook.slug)
    end
  end

  describe 'encryption' do
    it 'encrypts the verification_token' do
      token = 'very-secret-token'
      webhook = Fabricate(:webhook, verification_token: token)

      # Check that the raw token is not stored in the database
      raw_value = Webhook.where(id: webhook.id).pluck(:verification_token).first
      expect(raw_value).not_to eq(token)

      # But the decrypted value is accessible via the model
      expect(webhook.verification_token).to eq(token)
    end
  end

  describe '#slug' do
    it { expect(webhook.slug).not_to be_empty }
  end

  describe '#url' do
    around do |example|
      with_modified_env('HOSTNAME' => 'larcity.test') do
        example.run
      end
    end

    it 'returns the correct webhook URL' do
      expect(webhook.url).to eq("https://larcity.test/api/v2/webhooks/#{webhook.slug}/events")
    end
  end
end

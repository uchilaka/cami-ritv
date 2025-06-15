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
    it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }
    it { is_expected.to validate_length_of(:slug).is_at_most(64) }
    it { is_expected.to validate_presence_of(:verification_token) }
  end

  describe 'friendly_id' do
    # Example(s) https://github.com/norman/friendly_id?tab=readme-ov-file#example
    it { expect(Webhook.friendly.find(webhook.slug)).to eq(webhook) }
    it { is_expected.to have_attributes(to_param: webhook.slug) }
  end

  # TODO: We may have to turn on an option for encrypting fixtures(?) to assert that encryption is enabled.
  xdescribe 'encryption' do
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

  describe '#integration_id' do
    it 'returns the integration ID from data' do
      webhook.data = { integration_id: 'integration-123' }
      expect(webhook.integration_id).to eq('integration-123')
    end

    it 'returns nil if integration_id is not set' do
      webhook.data = {}
      expect(webhook.integration_id).to be_nil
    end
  end

  describe '#integration_name' do
    it 'returns the integration name from data' do
      webhook.data = { integration_name: 'Notion' }
      expect(webhook.integration_name).to eq('Notion')
    end

    it 'returns nil if integration_name is not set' do
      webhook.data = {}
      expect(webhook.integration_name).to be_nil
    end
  end
end

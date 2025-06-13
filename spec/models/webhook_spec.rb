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

  describe 'validations' do
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_length_of(:slug).is_at_most(64) }
    it { is_expected.to validate_presence_of(:verification_token) }
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

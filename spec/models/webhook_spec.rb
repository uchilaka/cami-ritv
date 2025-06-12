# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  readme             :text
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
end

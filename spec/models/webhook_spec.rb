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
require 'rails_helper'

RSpec.describe Webhook, type: :model do
  subject(:webhook) { described_class.new(url:, verification_token:) }

  let(:url) { 'https://example.com/webhook' }
  let(:verification_token) { 'secret-token' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:verification_token) }

    context 'with invalid URL' do
      let(:url) { 'invalid-url' }
      let(:error_message) { I18n.t('validators.errors.invalid_url', value: url) }

      before { webhook.valid? }

      it { is_expected.not_to be_valid }
      it { expect(webhook.errors[:url]).to include(error_message) }
    end

    context 'with valid URL' do
      let(:url) { 'https://valid-url.com' }

      it { is_expected.to be_valid }
    end
  end
end

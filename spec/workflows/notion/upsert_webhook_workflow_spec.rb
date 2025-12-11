# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::UpsertWebhookWorkflow do
  subject(:workflow) { described_class.call(**webhook_data) }

  let(:vendor) { :notion }
  let(:deal_database_id) { Faker::Alphanumeric.alpha(number: 32) }
  let(:vendor_database_id) { Faker::Alphanumeric.alpha(number: 32) }
  let(:shared_webhook_data) do
    {
      integration_id: 'test_integration_id',
      verification_token: 'test_verification_token',
    }
  end
  let(:webhook_data) { shared_webhook_data }
  let(:stub_credentials) { ActiveSupport::OrderedOptions.new }

  before do
    webhook_data.each_pair { |key, value| stub_credentials[key] = value }
    allow(Rails.application.credentials).to receive(vendor).and_return(stub_credentials)
  end

  describe '#call' do
    context "for 'deals' dataset" do
      let(:dataset) { :deal }
      let(:webhook_data) do
        {
          **shared_webhook_data,
          dataset:,
          database_id: deal_database_id,
          deal_database_id:,
          vendor_database_id:,
        }
      end

      context 'when webhook does not exist' do
        let(:webhook) { Webhook.find_by(slug: 'notion-deals') }

        it { expect { workflow }.to change { Webhook.count }.by(1) }
      end

      context 'when webhook already exists' do
        let(:expected_slug) { "#{vendor}-#{dataset.to_s.pluralize}" }
        let!(:existing_webhook) do
          Fabricate(:webhook, slug: expected_slug, dataset:, verification_token: webhook_data[:verification_token])
        end

        it { expect { workflow }.not_to(change { Webhook.count }) }
        xit { expect { workflow }.to(change { existing_webhook.data[:database_id] }) }
        xit { expect { workflow }.to change(existing_webhook.data, :deal_database_id) }
        xit { expect { workflow }.to change(existing_webhook.data, :vendor_database_id) }
        xit { expect { workflow }.to change(existing_webhook.data, :integration_id) }
        xit { expect { workflow }.to change(existing_webhook.data, :dashboard_url) }
      end
    end
  end
end

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
    shared_examples "updated Notion deals webhook" do
      subject(:webhook) { workflow.webhook }

      let(:expected_data) do
        {
          'deal_database_id' => deal_database_id,
          'vendor_database_id' => vendor_database_id,
          'integration_id' => webhook_data[:integration_id],
          'records_index_workflow_name' => Notion::Deals::DownloadLatestWorkflow.name.to_s,
          'record_download_workflow_name' => Notion::Deals::DownloadWorkflow.name.to_s,
        }
      end

      it { expect(webhook.data).to match(hash_including(expected_data)) }
      it { expect(webhook.records_index_workflow_name).to eq(Notion::Deals::DownloadLatestWorkflow.name.to_s) }
      it { expect(webhook.record_download_workflow_name).to eq(Notion::Deals::DownloadWorkflow.name.to_s) }
    end

    # TODO: Test backward compatibility support for command:
    #   `bin/thor [help] devkit:setup_webhooks`
    #   which relies on creating a Notion webhook without specifying
    #   a dataset.
    context 'when dataset is nil', skip: 'TODO: implement backward compatibility support' do
      let(:webhook_data) do
        {
          **shared_webhook_data,
          database_id: deal_database_id,
          dataset: nil,
          deal_database_id:,
          vendor_database_id:,
        }
      end

      context 'and webhook does not exist' do
        let(:webhook) { Webhook.find_by(slug: 'notion') }

        it { expect { workflow }.to change { Webhook.count }.by(1) }

        it_should_behave_like "updated Notion deals webhook"
      end
    end

    context 'when dataset is unsupported' do
      let(:database_id) { Faker::Alphanumeric.alpha(number: 32) }
      let(:webhook_data) do
        {
          **shared_webhook_data,
          dataset: :unsupported_dataset,
          database_id:,
          deal_database_id:,
          vendor_database_id:,
        }
      end
      let(:expected_message) do
        I18n.t(
          'workflows.notion.upsert_webhook_workflow.errors.unsupported_dataset',
          dataset: :unsupported_dataset
        )
      end

      # TODO: Implement a mocked test for custom_workflow_context_mater.rb
      it { is_expected.to have_failed_with_message(expected_message) }
      # it { expect { workflow }.to have_failed_with_message(expected_message) }
      # it { should have_failed_with_message(expected_message) }
    end

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

        it_should_behave_like "updated Notion deals webhook"
      end

      context 'when webhook already exists' do
        let!(:existing_webhook) do
          Fabricate(:webhook, slug: expected_slug, dataset:, verification_token: webhook_data[:verification_token])
        end

        let(:expected_slug) { "#{vendor}-#{dataset.to_s.pluralize}" }

        it('returns the existing webhook') { expect(workflow.webhook).to eq(existing_webhook) }

        it { expect { workflow }.not_to(change { Webhook.count }) }

        it_should_behave_like "updated Notion deals webhook"
      end
    end
  end
end

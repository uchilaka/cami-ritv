# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::Deals::DownloadWorkflow, type: :workflow do
  let(:webhook) { Fabricate :notion_webhook }
  let(:source_event) { create(:source_event, webhook: webhook) }
  let(:remote_record_id) { 'some-notion-page-id' }
  let(:record_data) { { 'id' => remote_record_id, 'properties' => {} } }
  let(:client) { instance_double(Notion::Client) }

  subject(:workflow) do
    described_class.call(
      webhook: webhook,
      source_event: source_event,
      remote_record_id: remote_record_id
    )
  end

  before do
    allow(Notion::Client).to receive(:new).and_return(client)
    allow(client).to receive(:get_entity).with(id: remote_record_id, type: 'page').and_return(record_data)
    allow_any_instance_of(described_class).to receive(:process_deal).and_return(double('Deal'))
  end

  describe '#call' do
    context 'when the download is successful' do
      it 'succeeds' do
        expect(workflow).to be_a_success
      end

      it 'fetches the remote record' do
        workflow
        expect(client).to have_received(:get_entity).with(id: remote_record_id, type: 'page')
      end

      it 'processes the result' do
        expect_any_instance_of(described_class).to receive(:process_deal).with(record_data)
        workflow
      end

      it 'assigns the processed record to the context' do
        expect(workflow.record).to be_present
      end
    end

    context 'when the Notion client returns no data' do
      let(:record_data) { nil }

      it 'fails' do
        expect(workflow).to be_a_failure
      end

      it 'returns an appropriate error message' do
        expect(workflow.message).to eq('No results returned from Notion')
      end
    end

    context 'when the Notion client raises an error' do
      let(:error_message) { 'Something went wrong' }

      before do
        allow(client).to receive(:get_entity).and_raise(StandardError, error_message)
      end

      it 'fails' do
        expect(workflow).to be_a_failure
      end

      it 'returns a formatted error message' do
        expect(workflow.message).to eq("Failed to download deal from Notion: #{error_message}")
      end
    end
  end
end


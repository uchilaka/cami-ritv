# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::Deals::DownloadWorkflow, type: :workflow do
  let(:webhook) { Fabricate :notion_webhook }
  let(:source_event) { nil }
  let(:remote_record_id) { SecureRandom.uuid }
  let(:record_data) do
    { 'object' => 'page', 'id' => remote_record_id, 'created_time' => '2025-08-09T17:52:00.000Z', 'last_edited_time' => '2025-08-25T00:37:00.000Z', 'created_by' => { 'object' => 'user', 'id' => '65a600e7-9de7-4bff-b158-07c1d4b1dc71' }, 'last_edited_by' => { 'object' => 'user', 'id' => '65a600e7-9de7-4bff-b158-07c1d4b1dc71' }, 'cover' => nil, 'icon' => { 'type' => 'external', 'external' => { 'url' => 'https://www.notion.so/icons/user-circle_blue.svg' } }, 'parent' => { 'type' => 'database_id', 'database_id' => '20f31362-3069-80b0-9196-d554bd3ab27a' }, 'archived' => false, 'in_trash' => false, 'is_locked' => false, 'properties' => { 'Expected close date' => { 'id' => '%3BQAq', 'type' => 'date', 'date' => nil }, 'Days since last contact' => { 'id' => '%3BilZ', 'type' => 'formula', 'formula' => { 'type' => 'string', 'string' => nil } }, 'Decision maker' => { 'id' => '%40pnJ', 'type' => 'people', 'people' => [] }, 'Deal value' => { 'id' => '%40tQ%3D', 'type' => 'number', 'number' => 375 }, 'Priority level' => { 'id' => 'H%7Dq%3A', 'type' => 'select', 'select' => { 'id' => '3631d1c6-1bfe-4848-8fc3-bce901df8d63', 'name' => 'Low', 'color' => 'gray' } }, 'Services' => { 'id' => 'LHI~', 'type' => 'relation', 'relation' => [], 'has_more' => false }, 'Notes' => { 'id' => 'LcT%7D', 'type' => 'rich_text', 'rich_text' => [] }, 'Lead source' => { 'id' => 'Rb%3DY', 'type' => 'multi_select', 'multi_select' => [] }, 'Phone number' => { 'id' => 'VAru', 'type' => 'phone_number', 'phone_number' => nil }, 'Account owner' => { 'id' => '%5CEJ%5B', 'type' => 'people', 'people' => [{ 'object' => 'user', 'id' => '65a600e7-9de7-4bff-b158-07c1d4b1dc71', 'name' => 'Uchenna Chilaka', 'avatar_url' => 'https://s3-us-west-2.amazonaws.com/public.notion-static.com/5c348c2a-b613-4a4a-8d17-dda310bdb77b/my-notion-face-customized.png', 'type' => 'person', 'person' => { 'email' => 'rdtyckrkyg@privaterelay.appleid.com' } }] }, 'Email' => { 'id' => '%60oJN', 'type' => 'email', 'email' => nil }, 'Last contact date' => { 'id' => 'yXIK', 'type' => 'date', 'date' => nil }, 'Deal stage' => { 'id' => 'y_%3D%3C', 'type' => 'select', 'select' => { 'id' => 'deed7c59-ee64-43db-9e45-c9eadb60f648', 'name' => 'Lost', 'color' => 'pink' } }, 'Name' => { 'id' => 'title', 'type' => 'title', 'title' => [{ 'type' => 'text', 'text' => { 'content' => 'Dancing Queens Inc', 'link' => nil }, 'annotations' => { 'bold' => false, 'italic' => false, 'strikethrough' => false, 'underline' => false, 'code' => false, 'color' => 'default' }, 'plain_text' => 'Dancing Queens Inc', 'href' => nil }] } }, 'url' => 'https://www.notion.so/Dancing-Queens-Inc-24a31362306980089254ce1db0e13474', 'public_url' => nil, 'request_id' => '9a5f7efc-217f-4f74-a839-da2774148479' }
  end
  let(:client) { instance_double(Notion::Client) }

  subject(:workflow_call) { described_class.call(webhook:, source_event:, remote_record_id:) }

  before do
    allow(Notion::Client).to receive(:new).and_return(client)
    # TODO: Use a cassette for this instead of stubbing
    allow(client).to receive(:get_entity).with(id: remote_record_id, type: 'page').and_return(record_data)
    allow_any_instance_of(described_class).to receive(:process_deal).and_return(instance_double(Struct::Deal))
  end

  describe '#call' do
    context 'when the download is successful' do
      it 'succeeds' do
        expect(workflow_call).to be_a_success
      end

      it 'fetches the remote record' do
        workflow_call
        expect(client).to have_received(:get_entity).with(id: remote_record_id, type: 'page')
      end

      it 'processes the result' do
        expect_any_instance_of(described_class).to receive(:process_deal).with(record_data)
        workflow_call
      end

      it 'assigns the processed record to the context' do
        expect(workflow_call.record).to be_present
      end
    end

    context 'when the Notion client returns no data' do
      let(:record_data) { nil }
      let(:error_message) { 'No data returned from Notion' }

      let!(:result) { workflow_call }

      it { is_expected.to be_a_failure }
      it { expect(result).to have_attributes(message: error_message) }
    end

    context 'when the Notion client raises an error' do
      let(:error_message) { 'Something went wrong' }
      let(:result) { workflow_call }

      before do
        allow(client).to receive(:get_entity).and_raise(StandardError, error_message)
      end

      it { is_expected.to be_a_failure }
      it { expect(result).to have_attributes(message: error_message) }
    end
  end
end


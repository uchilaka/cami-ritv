# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::DealUpdatedEvent, type: :model do
  let(:database_id) { SecureRandom.uuid }
  let(:integration_id) { SecureRandom.uuid }
  let(:entity_id) { SecureRandom.uuid }
  let(:workspace_id) { "ws_#{SecureRandom.hex(8)}" }
  let(:subscription_id) { "sub_#{SecureRandom.hex(8)}" }

  let(:metadatum_attributes) do
    {
      key: 'notion.deal_updated',
      value: {
        integration_id:,
        database_id:,
        entity_id:,
        workspace_id:,
        workspace_name: 'Test Workspace',
        subscription_id:,
      },
    }
  end

  let(:metadatum) { Fabricate(:notion_webhook_event_metadatum, **metadatum_attributes) }
  let(:webhook) { Fabricate(:webhook, integration: :notion) }

  subject(:event) { Fabricate(:deal_updated_event, integration: :notion, metadatum:) }

  before do
    event.eventable = webhook
    event.save!
  end

  describe 'attributes' do
    it { is_expected.to be_valid }
    it { is_expected.to have_attributes(entity_id:) }
    it { is_expected.to have_attributes(integration_id:) }
    it { is_expected.to have_attributes(database_id:) }
    it { is_expected.to have_attributes(remote_record_id: entity_id) }
    it { is_expected.to have_attributes(workspace_id:) }
    it { is_expected.to have_attributes(subscription_id:) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:eventable).optional }
    it { is_expected.to have_one(:metadatum).class_name('Notion::WebhookEventMetadatum') }
    it { is_expected.to accept_nested_attributes_for(:metadatum) }
    it { is_expected.to have_attributes(metadatum:) }
    it { is_expected.to have_attributes(eventable: webhook) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:integration_id) }
    it { is_expected.to validate_presence_of(:database_id) }
    it { is_expected.to validate_presence_of(:workspace_id) }
    it { is_expected.to validate_presence_of(:subscription_id) }
  end

  describe 'instantiation' do
    it 'can be instantiated' do
      expect { described_class.new }.not_to raise_error
    end

    it 'inherits from BaseEvent' do
      expect(described_class.superclass).to eq(Notion::BaseEvent)
    end
  end

  describe 'delegated methods' do
    it 'delegates methods to metadatum' do
      expect(event.workspace_id).to eq(workspace_id)
      expect(event.workspace_name).to eq('Test Workspace')
      expect(event.subscription_id).to eq(subscription_id)
    end
  end

  describe 'state machine' do
    subject(:event) { described_class.new }

    it { is_expected.to have_state(:pending) }
    it { is_expected.to allow_event(:process) }
    it { is_expected.to allow_event(:complete) }
    it { is_expected.to allow_event(:fail) }

    describe 'transitions' do
      it { is_expected.to transition_from(:pending).to(:processing).on_event(:process) }
      it { is_expected.to transition_from(:processing).to(:completed).on_event(:complete) }
      it { is_expected.to transition_from(:pending).to(:failed).on_event(:fail) }
      it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
    end
  end

  describe 'metadatum association' do
    it 'is destroyed when event is destroyed' do
      metadatum_id = event.metadatum.id
      event.destroy
      expect(Notion::WebhookEventMetadatum.find_by(id: metadatum_id)).to be_nil
    end
  end
end

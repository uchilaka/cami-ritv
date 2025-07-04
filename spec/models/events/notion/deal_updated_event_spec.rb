# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::DealUpdatedEvent, type: :model do
  let(:database_id) { SecureRandom.uuid }
  let(:integration_id) { SecureRandom.uuid }
  let(:entity_id) { SecureRandom.uuid }
  let(:workspace_id) { "ws_#{SecureRandom.hex(8)}" }
  let(:subscription_id) { "sub_#{SecureRandom.hex(8)}" }
  let(:attempt_number) { 6 }

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
        attempt_number:,
      },
    }
  end

  let(:metadatum) { Fabricate(:notion_webhook_event_metadatum, variant: :deal_updated, **metadatum_attributes) }
  let(:webhook) { Fabricate(:webhook, integration: :notion) }

  subject(:event) { Fabricate(:deal_updated_event, integration: :notion, metadatum:, eventable: webhook) }

  describe 'attributes' do
    it { is_expected.to be_valid }
    it { is_expected.to have_attributes(entity_id:) }
    it { is_expected.to have_attributes(integration_id:) }
    it { is_expected.to have_attributes(database_id:) }
    it { is_expected.to have_attributes(remote_record_id: entity_id) }
    it { is_expected.to have_attributes(workspace_id:) }
    it { is_expected.to have_attributes(attempt_number:) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:eventable).optional }
    xit { is_expected.to have_one(:metadatum).class_name('Notion::WebhookEventMetadatum') }
    it { is_expected.to accept_nested_attributes_for(:metadatum) }
    it { is_expected.to have_attributes(metadatum:) }
    it { is_expected.to have_attributes(eventable: webhook) }
  end

  describe 'validations' do
    context 'when metadatum is present' do
      it { is_expected.to be_valid }
    end

    context 'when metadatum is missing' do
      subject(:invalid_event) { described_class.new(metadatum: nil) }

      it 'is not valid' do
        expect(invalid_event).not_to be_valid
        expect(invalid_event.errors[:metadatum]).to include("can't be blank")
      end
    end

    context 'when metadatum has missing attributes' do
      let(:metadatum) { Fabricate(:notion_webhook_event_metadatum, variant: :deal_created, value: {}) }
      subject(:event) { described_class.new(metadatum:) }

      it 'validates presence of required attributes' do
        expect(event).not_to be_valid
        expect(event.errors[:entity_id]).to include("can't be blank")
        expect(event.errors[:integration_id]).to include("can't be blank")
        expect(event.errors[:database_id]).to include("can't be blank")
        expect(event.errors[:remote_record_id]).to include("can't be blank")
      end
    end

    describe '#attempt_number' do
      context 'when invalid' do
        let(:attempt_number) { 0 }

        it do
          expect { subject }.to \
            raise_error(ActiveRecord::RecordInvalid, /Attempt number must be an integer greater than or equal to 1/)
        end
      end

      context 'when missing' do
        let(:attempt_number) { nil }

        it do
          expect { subject }.to \
            raise_error(ActiveRecord::RecordInvalid, /Attempt number must be an integer greater than or equal to 1/)
        end
      end
    end
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
    it { expect(event.workspace_id).to eq(workspace_id) }
    it { expect(event.workspace_name).to eq(metadatum.workspace_name) }
    it { expect(event.entity_id).to eq(entity_id) }
    it { expect(event.integration_id).to eq(integration_id) }
    it { expect(event.database_id).to eq(database_id) }
    it { expect(event.remote_record_id).to eq(entity_id) }
    it { expect(event.attempt_number).to eq(6) }
  end

  describe 'state machine' do
    subject(:event) { described_class.new }

    it { is_expected.to have_state(:pending) }
    it { is_expected.to allow_event(:process) }
    # TODO: Replace this with a proper test for the `complete` event
    xit { is_expected.to allow_event(:complete) }
    it { is_expected.to allow_event(:fail) }

    describe 'transitions' do
      it { is_expected.to transition_from(:pending).to(:processing).on_event(:process) }
      it { is_expected.to transition_from(:pending).to(:failed).on_event(:fail) }

      context 'from processing' do
        before { event.status = :processing }

        it { is_expected.to transition_from(:processing).to(:completed).on_event(:complete) }
        it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
      end
    end

    describe 'state behaviors' do
      it 'has the correct states defined' do
        expect(described_class.aasm.states.map(&:name)).to contain_exactly(
          :pending, :processing, :completed, :failed
        )
      end

      it 'has the correct events defined' do
        expect(described_class.aasm.events.map(&:name)).to contain_exactly(
          :process, :complete, :fail
        )
      end
    end
  end
end

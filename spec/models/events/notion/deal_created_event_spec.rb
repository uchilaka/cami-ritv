# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::DealCreatedEvent, type: :model do
  let(:database_id) { SecureRandom.uuid }
  let(:integration_id) { SecureRandom.uuid }
  let(:entity_id) { SecureRandom.uuid }
  let(:metadatum) do
    Fabricate(:notion_webhook_event_metadatum,
              key: 'notion.deal_created',
              value: { integration_id:, database_id:, entity_id: })
  end
  let(:webhook) { Fabricate(:webhook, integration: :notion) }

  subject(:event) { Fabricate(:deal_created_event, integration: :notion, metadatum:) }

  before do
    event.eventable = webhook
    event.save!
  end

  it { is_expected.to have_attributes(entity_id:) }
  it { is_expected.to have_attributes(integration_id:) }
  it { is_expected.to have_attributes(database_id:) }
  it { is_expected.to have_attributes(remote_record_id: entity_id) }

  describe 'associations' do
    it { is_expected.to be_valid }
    it { is_expected.to belong_to(:eventable).optional }
    it { is_expected.to have_one(:metadatum).optional.dependent(:destroy) }
    it { is_expected.to have_attributes(metadatum:) }
    it { is_expected.to have_attributes(eventable: webhook) }
  end

  describe 'inheritance' do
    it 'inherits from GenericEvent' do
      expect(described_class.superclass).to eq(GenericEvent)
    end
  end

  describe 'instantiation' do
    it 'can be instantiated' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe 'state machine' do
    subject(:event) { described_class.new }

    let(:deal_created) { described_class.new }

    it { is_expected.to have_state(:pending) }

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

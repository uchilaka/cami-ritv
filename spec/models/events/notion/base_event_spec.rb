# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::BaseEvent, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:metadatum).class_name('Notion::WebhookEventMetadatum') }
    it { is_expected.to accept_nested_attributes_for(:metadatum) }
  end

  describe 'delegations' do
    let(:metadatum) { Fabricate.build(:notion_webhook_event_metadatum) }
    let(:event) { Fabricate.build(:notion_base_event, metadatum:) }

    %i[
      entity_id
      integration_id
      database_id
      workspace_id
      workspace_name
      remote_record_id
    ].each do |method|
      it { is_expected.to delegate_method(method).to(:metadatum) }
    end

    it 'aliases remote_record_id to entity_id' do
      expect(event.remote_record_id).to eq(event.entity_id)
    end
  end

  describe 'state machine' do
    let(:event) { Fabricate.build(:notion_base_event) }

    describe 'initial state' do
      it 'is pending' do
        expect(event).to have_state(:pending)
      end
    end

    describe 'transitions' do
      it 'from pending to processing' do
        expect(event).to transition_from(:pending).to(:processing).on_event(:process)
      end

      it 'from processing to completed' do
        event.process!
        expect(event).to transition_from(:processing).to(:completed).on_event(:complete)
      end

      it 'from pending to failed' do
        expect(event).to transition_from(:pending).to(:failed).on_event(:fail)
      end

      it 'from processing to failed' do
        event.process!
        expect(event).to transition_from(:processing).to(:failed).on_event(:fail)
      end
    end
  end

  describe 'validations' do
    subject { Fabricate.build(:notion_base_event) }
    it { is_expected.to be_valid }
  end
end

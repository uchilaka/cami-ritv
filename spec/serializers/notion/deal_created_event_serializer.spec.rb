# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::DealCreatedEventSerializer, type: :serializer do
  let(:metadatum) do
    Fabricate(:notion_webhook_event_metadatum, variant: :deal_created)
  end
  let(:eventable) { Fabricate(:notion_webhook) }
  let(:deal_event) do
    Fabricate(:deal_created_event, integration: :notion, eventable:, metadatum:)
  end

  subject { described_class.new(deal_event) }

  describe '#attributes' do
    let(:result) { subject.attributes }

    it { expect(result[:id]).to eq deal_event.id }

    it { expect(result[:workspace_id]).to eq deal_event.metadatum.value['workspace_id'] }

    it { expect(result[:workspace_name]).to eq deal_event.metadatum.value['workspace_name'] }

    it { expect(result[:subscription_id]).to eq deal_event.metadatum.value['subscription_id'] }

    it { expect(result[:integration_id]).to eq deal_event.integration_id }

    it { expect(result[:remote_record_id]).to eq deal_event.remote_record_id }

    it { expect(result[:entity_id]).to eq deal_event.entity_id }

    it { expect(result[:database_id]).to eq deal_event.database_id }

    it 'has the correct created_at timestamp' do
      expect(result[:created_at]).to be_within(1.second).of(deal_event.created_at)
    end

    it 'has the correct updated_at timestamp' do
      expect(result[:updated_at]).to be_within(1.second).of(deal_event.updated_at)
    end

    it { expect(result[:type]).to eq deal_event.type }

    it { expect(result[:entity]).to eq deal_event.entity }

    it { expect(result[:database]).to eq deal_event.database }
  end
end

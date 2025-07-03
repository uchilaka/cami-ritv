# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::DealUpdatedEventSerializer do
  let(:metadatum) do
    double(
      'Metadatum',
      value: {
        'entity' => { 'id' => 'entity-123' },
        'database' => { 'id' => 'db-456' },
        'workspace_id' => 'ws-789',
        'workspace_name' => 'Test Workspace',
        'subscription_id' => 'sub-101',
      }
    )
  end

  let(:deal_event) do
    double(
      'DealEvent',
      id: 1,
      metadatum:,
      integration_id: 'int-202',
      remote_record_id: 'remote-303',
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
      type: 'deal_updated',
      entity: 'deal',
      database: 'deals_db'
    )
  end

  subject { described_class.new(deal_event) }

  describe '#attributes' do
    it 'serializes the correct attributes' do
      result = subject.attributes
      expect(result[:id]).to eq 1
      expect(result[:workspace_id]).to eq 'ws-789'
      expect(result[:workspace_name]).to eq 'Test Workspace'
      expect(result[:subscription_id]).to eq 'sub-101'
      expect(result[:integration_id]).to eq 'int-202'
      expect(result[:remote_record_id]).to eq 'remote-303'
      expect(result[:entity_id]).to eq 'entity-123'
      expect(result[:database_id]).to eq 'db-456'
      expect(result[:created_at]).to be_within(1.second).of(deal_event.created_at)
      expect(result[:updated_at]).to be_within(1.second).of(deal_event.updated_at)
      expect(result[:type]).to eq 'deal_updated'
      expect(result[:entity]).to eq 'deal'
      expect(result[:database]).to eq 'deals_db'
    end
  end
end


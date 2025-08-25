# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhooks::EventSearchQuery do
  subject(:query) { described_class.new(search_query, params:, fields:) }

  let(:search_query) { nil }
  let(:fields) { %w[slug status] }
  let(:common_params) { %i[webhook_id event_id id page q] }
  let(:hash_permitted_params) { { f: {}, s: {} } }
  let(:array_permitted_params) { { f: %i[field value], s: %i[field direction] } }
  let(:params_input) { {} }
  let(:hash_params) do
    ActionController::Parameters
      .new(params_input)
      .permit(*common_params, **hash_permitted_params)
  end
  let(:array_params) do
    ActionController::Parameters
      .new(params_input)
      .permit(*common_params, **array_permitted_params)
  end

  describe '#compose_sorters' do
    subject(:sorters) { query.send(:compose_sorters) }

    context 'when sort params is a Hash' do
      let(:params_input) { { 's' => { createdAt: 'desc', updatedAt: 'asc' } } }
      let(:params) { hash_params }

      it { expect(sorters).to include('created_at DESC', 'updated_at ASC') }
    end

    context 'when sort params is an Array' do
      let(:params_input) do
        {
          's' => [
            { 'field' => 'createdAt', 'direction' => 'desc' },
            { 'field' => 'updatedAt', 'direction' => 'asc' },
          ],
        }
      end
      let(:params) { array_params }

      it { expect(sorters).to include('created_at DESC', 'updated_at ASC') }
    end

    context 'when sort params is blank' do
      let(:input_params) { {} }
      let(:params) { hash_params }

      it('returns default sorters') { expect(subject).to eq(['created_at DESC']) }
    end
  end

  describe '#compose_predicates' do
    pending "add examples for predicates composition"
  end

  describe '#compose_filters' do
    pending "add examples for filters composition"
  end
end


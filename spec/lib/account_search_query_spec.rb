# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSearchQuery, type: :query do
  let(:qs) { nil }
  let(:params) { {} }

  subject do
    filtered_params =
      ActionController::Parameters.new(params).permit(:q, f: {}, s: {})
    described_class.new(qs, params: filtered_params)
  end

  it { expect(subject).to respond_to(:query_string) }
  it { expect(subject).to respond_to(:params) }
  it { expect(subject).to respond_to(:filters) }
  it { expect(subject).to respond_to(:sorters) }
  it { expect(subject).to respond_to(:predicates) }
  it { expect(subject).to respond_to(:rebuild) }

  shared_examples 'search by query string' do |qs, expected_predicates|
    let(:params) do
      { 'q' => qs }
    end

    subject do
      filtered_params =
        ActionController::Parameters.new(params).permit(:q, :mode, f: {}, s: {})
      described_class.new(qs, params: filtered_params)
    end

    context 'without other parameters' do
      it { expect(subject.predicates).to match(expected_predicates) }
    end

    context 'with blankish values of other parameters' do
      let(:params) do
        {
          'q' => qs,
          'f' => {},
          's' => {},
        }
      end

      it { expect(subject.predicates).to match(expected_predicates) }
    end

    context 'with sorting' do
      let(:params) do
        {
          'q' => qs,
          's' => {
            'status' => 'asc',
            'updatedAt' => 'desc',
          },
        }
      end

      it { expect(subject.predicates).to match(expected_predicates) }
      it { expect(subject.sorters).to include('status asc') }
      it { expect(subject.sorters).to include('updated_at desc') }
    end
  end

  context 'with query string' do
    it_should_behave_like 'search by query string',
                          'AEL',
                          {
                            'display_name_or_email_or_slug_or_tax_id_cont' => 'AEL',
                          }
  end
end

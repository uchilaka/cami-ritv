# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notion::DealCreated, type: :model do
  describe 'associations' do
    it { should belong_to(:metadatum).optional.dependent(:destroy) }
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
end

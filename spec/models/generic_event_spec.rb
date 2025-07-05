# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEvent, type: :model do
  let(:eventable) { Fabricate(:account, slug: Faker::Internet.slug) } # Using account as an example eventable
  let(:generic_event) { Fabricate.build(:generic_event, eventable:) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:type) }

    it 'validates presence of metadatum for non-GenericEvent types' do
      event = Fabricate.build(:deal_created_event, integration: :notion, eventable:)
      expect(event).to validate_presence_of(:metadatum).with_message(/must exist/)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:eventable).optional }
    it { is_expected.to have_one(:metadatum).dependent(:destroy) }
  end

  describe 'friendly_id' do
    context 'when creating a new event' do
      it 'generates a slug' do
        event = Fabricate(:generic_event, eventable:)
        expect(event.slug).to be_present
      end

      it 'regenerates slug if slug is blank' do
        event = Fabricate(:generic_event, eventable:, slug: nil)
        expect(event.slug).to be_present
      end

      it 'does not regenerate slug if slug is present' do
        event = Fabricate(:generic_event, eventable:, slug: 'custom-slug')
        expect(event.slug).to eq('custom-slug')
      end
    end
  end

  describe '#eventable_slug' do
    it 'returns the slug of the associated eventable' do
      expect(generic_event.eventable_slug).to eq(eventable.slug)
    end

    it 'returns nil if no eventable is associated' do
      generic_event.eventable = nil
      expect(generic_event.eventable_slug).to be_nil
    end
  end

  describe '#variant' do
    it { expect(generic_event.variant).to eq('generic') }
  end

  describe '#should_generate_new_friendly_id?' do
    it 'returns true when slug is blank' do
      generic_event.slug = nil
      expect(generic_event.should_generate_new_friendly_id?).to be true
    end

    it 'returns false when slug is present' do
      generic_event.slug = 'existing-slug'
      expect(generic_event.should_generate_new_friendly_id?).to be false
    end
  end
end

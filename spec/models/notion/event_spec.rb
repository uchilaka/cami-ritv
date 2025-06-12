# frozen_string_literal: true

require 'rails_helper'

describe Notion::Event do
  let(:event_id) { SecureRandom.uuid }
  let(:event_data) do
    {
      id: event_id,
      type: 'page.created',
      entity: {
        id: SecureRandom.uuid,
        type: 'page',
      },
      parent: {
        id: SecureRandom.uuid,
        type: 'database',
      },
      authors: [
        {
          id: SecureRandom.uuid,
          type: 'user',
        },
      ],
    }
  end

  subject(:event) { described_class.new(data: event_data) }

  it { expect(event.parent).to be_a(Notion::Database) }

  describe 'validations' do
    before { event.valid? }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:type) }

    context 'with invalid attributes' do
      describe '#data' do
        it 'is invalid with a nil data' do
          invalid_event = described_class.new(type: 'page.created', data: nil)
          expect(invalid_event).not_to be_valid
          expect(invalid_event.errors[:data]).to include("can't be blank")
        end

        it 'is invalid with an empty data hash' do
          invalid_event = described_class.new(type: 'page.created', data: {})
          expect(invalid_event).not_to be_valid
          expect(invalid_event.errors[:data]).to include("can't be blank")
        end
      end


      it 'is invalid without a type' do
        invalid_event = described_class.new(data: { key: 'value' })
        expect(invalid_event).not_to be_valid
        expect(invalid_event.errors[:type]).to include("can't be blank")
      end

      it 'is invalid without data' do
        invalid_event = described_class.new(type: 'page.created')
        expect(invalid_event).not_to be_valid
        expect(invalid_event.errors[:data]).to include("can't be blank")
      end

      it 'is invalid with an empty data hash' do
        invalid_event = described_class.new(type: 'page.created', data: {})
        expect(invalid_event).not_to be_valid
        expect(invalid_event.errors[:data]).to include("can't be blank")
      end
    end

    it 'is invalid with an unsupported type' do
      invalid_event = described_class.new(type: 'invalid_type')
      expect(invalid_event).not_to be_valid
      expect(invalid_event.errors[:type]).to include('is not included in the list')
    end
  end

  describe 'attributes' do
    it 'has a type' do
      expect(event.type).to eq('page.created')
    end

    it 'has an entity as an Entity object' do
      expect(event.entity).to be_a_kind_of(Notion::Entity)
    end

    it 'has data' do
      expect(event.data).to eq(event_data)
    end

    it 'sets timestamp by default' do
      expect(event.timestamp).to be_a(Time)
    end

    it 'defaults attempt_number to 1' do
      expect(event.attempt_number).to eq(1)
    end
  end

  describe 'entity initialization' do
    let(:entity_id) { SecureRandom.uuid }

    context 'with method argument attributes' do
      subject(:event) do
        described_class.new(
          id: event_id,
          type: 'page.created',
          data: {},
          entity: { id: entity_id, type: 'page' }
        )
      end

      it { expect(event.entity).to be_a(Notion::Entity) }

      it 'has expected attributes' do
        expect(event.entity).to have_attributes(id: entity_id, type: 'page')
      end
    end

    context 'with data attributes' do
      let(:entity_id) { SecureRandom.uuid }
      let(:event_data) do
        {
          id: event_id,
          type: 'page.deleted',
          entity: { id: entity_id, type: 'page' },
        }
      end

      it { expect(event.entity).to be_a(Notion::Entity) }

      it 'initializes entity with provided attributes' do
        expect(event.entity).to \
          have_attributes(id: entity_id, type: event_data.dig(:entity, :type))
      end
    end
  end

  describe '#attributes' do
    it 'returns a hash' do
      expect(event.attributes).to be_a(Hash)
    end
  end

  describe '#parent' do
    let(:parent_id) { SecureRandom.uuid }
    let(:parent_type) { 'database' }

    subject(:event) do
      described_class
        .new(
          id: event_id,
          data: {
            parent: { id: parent_id, type: parent_type },
          }
        )
    end

    it 'returns a Notion::Entity object if parent is present in data' do
      expect(event.parent).to be_a(Notion::Database)
      expect(event.parent.id).to eq(parent_id)
      expect(event.parent.type).to eq('database')
    end

    context 'without parent data' do
      subject(:event) { described_class.new(id: event_id, type: 'page.created', data: {}) }

      it 'returns nil' do
        expect(event.parent).to be_nil
      end
    end
  end

  describe '#authors' do
    context 'when authors are present in data' do
      let(:event_data) do
        {
          id: SecureRandom.uuid,
          type: 'page.created',
          authors: [
            { id: SecureRandom.uuid, type: 'user' },
            { id: SecureRandom.uuid, type: 'user' },
          ],
        }
      end

      it { expect(event.authors).to all(be_a(Notion::Entity)) }
    end

    context 'when authors are not present in data' do
      let(:event_data) { { id: SecureRandom.uuid, type: 'page.created' } }

      it 'returns an empty array' do
        expect(event.authors).to eq([])
      end
    end
  end
end

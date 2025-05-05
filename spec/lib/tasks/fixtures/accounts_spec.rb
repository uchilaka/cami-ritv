# frozen_string_literal: true

require 'rails_helper'

# load_lib_script 'tasks/fixtures/accounts', ext: 'thor'

load 'lib/tasks/fixtures/accounts.thor'

RSpec.describe Fixtures::Accounts do
  let(:fixtures) do
    [
      { display_name: 'Acme Corp', slug: 'acme-corp', tax_id: '123-45-6789' },
      { display_name: 'Widget Co', slug: 'widget-co', tax_id: '987-65-4321' }
    ].map(&:stringify_keys)
  end

  before do
    allow(YAML).to receive(:load).and_return(fixtures)
  end

  describe '#load' do
    subject { described_class.new.invoke(:load, []) }

    it 'loads the fixtures' do
      expect { subject }.to change(Account, :count).by(2)
    end

    context 'when the fixtures have already been loaded' do
      before { Fabricate(:account, slug: 'acme-corp') }

      it 'loads only the new fixtures' do
        expect { subject }.to change(Account, :count).by(1)
      end
    end

    context 'when the fixtures are missing tax id' do
      let(:fixtures) do
        [
          { display_name: 'Acme Corp', slug: 'acme-corp' },
          { display_name: 'Widget Co', slug: 'widget-co' }
        ]
      end

      it 'loads the fixtures' do
        expect { subject }.to change(Account, :count).by(2)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

module LarCity
  RSpec.describe GeoRegions do
    describe '.countries' do
      subject(:geo_region) { described_class.countries }

      it { expect(geo_region).to be_a(Hash) }

      # US
      it do
        expect(geo_region['US']).to \
          include(name: 'United States of America', alpha_2: 'US', country_code: '840')
      end

      # UK
      it do
        expect(geo_region['GB']).to \
          include(name: 'United Kingdom of Great Britain and Northern Ireland', alpha_2: 'GB', country_code: '826')
      end

      # NL
      it do
        expect(geo_region['NL']).to \
          include(name: 'Kingdom of the Netherlands', alpha_2: 'NL', country_code: '528')
      end

      # TW
      it do
        expect(geo_region['TW']).to \
          include(name: 'Taiwan, Province of China', alpha_2: 'TW', country_code: '158')
      end
      
      # SH
      it do
        expect(geo_region['SH']).to \
          include(name: 'Saint Helena, Ascension and Tristan da Cunha', alpha_2: 'SH', country_code: '654')
      end
    end

    describe '.lookup' do
      let(:countries) do
        {
          'US' => { name: 'United States of America', alpha_2: 'US', country_code: '840' },
          'GB' => { name: 'United Kingdom', alpha_2: 'GB', country_code: '826' },
          'JP' => { name: 'Japan', alpha_2: 'JP', country_code: '392' },
        }
      end

      before do
        allow(described_class).to receive(:countries).and_return(countries)
      end

      it 'returns the full country hash when no attribute is specified' do
        expect(described_class.lookup('US')).to eq(countries['US'])
      end

      it 'returns the specific attribute when provided' do
        expect(described_class.lookup('GB', :name)).to eq('United Kingdom')
        expect(described_class.lookup('JP', :alpha_2)).to eq('JP')
      end

      it 'returns nil for an unknown country code' do
        expect(described_class.lookup('ZZ')).to be_nil
      end

      it 'returns nil for a blank input' do
        expect(described_class.lookup(nil)).to be_nil
        expect(described_class.lookup('')).to be_nil
      end
    end
  end
end

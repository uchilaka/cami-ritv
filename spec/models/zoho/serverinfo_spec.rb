# frozen_string_literal: true

require 'rails_helper'

module Zoho
  RSpec.describe Serverinfo, type: :model do
    subject(:config) { Fabricate :zoho_serverinfo }

    shared_examples 'a supported serverinfo region' do |region_alpha2, endpoint, region_name = nil|
      subject(:config) do
        Fabricate(
          :zoho_serverinfo,
          value: {
            oauth: {
              region_alpha2:,
              region_name:,
              endpoint:,
            }.compact,
          }
        )
      end

      it { expect(config.serializable_hash).to include(region: region_alpha2.to_s.upcase) }
      it { expect(config.serializable_hash).to include(endpoint:) }
    end

    describe '#endpoint' do
      subject(:config) do
        Fabricate(
          :zoho_serverinfo,
          value: {
            oauth: {
              region_alpha2: 'JP',
              endpoint: 'https://accounts.zoho.jp',
            },
          }
        )
      end

      it { expect(config.endpoint).to eq('https://accounts.zoho.jp') }
    end

    describe '#region_name' do
      subject(:config) do
        Fabricate(
          :zoho_serverinfo,
          value: {
            oauth: {
              region_alpha2: 'JP',
              endpoint: 'https://accounts.zoho.jp',
            },
          }
        )
      end

      it { expect(config.region_name).to eq('Japan') }
    end

    describe '#serializable_hash' do
      it { expect(config.serializable_hash).to include(key: 'https://accounts.zoho.com/oauth/serverinfo') }

      # EU
      it_behaves_like 'a supported serverinfo region', 'EU', 'https://accounts.zoho.eu'
      # IN
      it_behaves_like 'a supported serverinfo region', 'IN', 'https://accounts.zoho.in'
      # UK
      it_behaves_like 'a supported serverinfo region', 'UK', 'https://accounts.zoho.uk'
      # SA
      it_behaves_like 'a supported serverinfo region', 'SA', 'https://accounts.zoho.sa'
      # CA
      it_behaves_like 'a supported serverinfo region', 'CA', 'https://accounts.zoho.ca'
    end
  end
end

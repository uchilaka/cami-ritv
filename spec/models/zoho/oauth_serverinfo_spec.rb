# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata
#
#  id              :uuid             not null, primary key
#  appendable_type :string
#  key             :string           not null
#  type            :string           default("Metadatum"), not null
#  value           :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  appendable_id   :uuid
#
# Indexes
#
#  index_for_zoho_oauth_serverinfo_metadata  (((value ->> 'region_alpha2'::text)))
#  index_metadata_on_appendable              (appendable_type,appendable_id)
#
require 'rails_helper'

module Zoho
  RSpec.describe OauthServerinfo, type: :model do
    subject(:config) { Fabricate :zoho_oauth_serverinfo }

    shared_examples 'a supported serverinfo region' do |region_alpha2, endpoint, region_name = nil|
      subject(:config) do
        Fabricate(
          :zoho_oauth_serverinfo,
          value: {
            region_alpha2:,
            region_name:,
            endpoint:,
          }.compact
        )
      end

      it { expect(config.serializable_hash).to include(region: region_alpha2.to_s.upcase) }
      it { expect(config.serializable_hash).to include(endpoint:) }
    end

    describe '#endpoint' do
      subject(:config) do
        Fabricate(
          :zoho_oauth_serverinfo,
          value: {
            region_alpha2: 'JP',
            endpoint: 'https://accounts.zoho.jp',
          }
        )
      end

      it { expect(config.endpoint).to eq('https://accounts.zoho.jp') }
    end

    describe '#region_name' do
      subject(:config) do
        Fabricate(
          :zoho_oauth_serverinfo,
          value: {
            region_alpha2: 'JP',
            endpoint: 'https://accounts.zoho.jp',
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

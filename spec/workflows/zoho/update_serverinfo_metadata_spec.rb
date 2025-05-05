# frozen_string_literal: true

require 'rails_helper'

module Zoho
  RSpec.describe UpdateServerinfoMetadata, type: :interactor do
    # VCR configuration
    let(:cassette) { vcr_cassettes[:zoho] }
    # Comment out this declaration if you're working on updating cassettes
    let(:cassette_options) do
      cassette[:options]
        .deep_merge(
          match_requests_on: %i[method uri],
          record: :once
        )
    end
    # Un-comment this line if you're working on updating cassettes
    # let(:cassette_options) { cassette[:options] }
    around do |example|
      # Edit the cassette options for :zoho at config/vcr.yml
      VCR.use_cassette('zoho/serverinfo', cassette_options) { example.run }
    end
    # End VCR configuration

    describe '#call' do
      it 'creates or updates Zoho::OauthServerinfo records' do
        expect { described_class.call }.to change(Zoho::OauthServerinfo, :count).by(8)
      end

      it 'updates existing records without creating duplicates' do
        existing_record = Zoho::OauthServerinfo.create!(
          key: 'https://accounts.zoho.com',
          value: {
            endpoint: 'https://accounts.zoho.com',
            region_name: 'United States of America',
            resource_url: 'https://accounts.zoho.com/oauth/serverinfo',
            region_alpha2: 'US',
          }
        )

        expect { described_class.call }.to change(Zoho::OauthServerinfo, :count).by(7)

        existing_record.reload
        expect(existing_record.region_name).to eq('United States of America')
        expect(existing_record.region_alpha2).to eq('US')
        expect(existing_record.endpoint).to eq('https://accounts.zoho.com/oauth/serverinfo')
      end

      it 'raises an error if saving a record fails' do
        allow_any_instance_of(Zoho::OauthServerinfo).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

        expect { described_class.call }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
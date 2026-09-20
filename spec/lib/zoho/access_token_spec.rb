# frozen_string_literal: true

require 'rails_helper'

module Zoho
  RSpec.describe AccessToken do
    before do
      load_zoho_serverinfo
    end

    describe '#generate' do
      # VCR configuration -- replays the recorded POST /oauth/v2/token. Without it this
      # example performs a live token grant and goes red whenever Zoho rate-limits.
      let(:cassette) { vcr_cassettes[:zoho] }
      let(:cassette_options) do
        cassette[:options].deep_merge(
          match_requests_on: %i[method uri],
          record: :none
        )
      end

      around do |example|
        VCR.use_cassette('zoho/access_token', cassette_options) { example.run }
      end
      # End VCR configuration

      subject { described_class.generate }

      it 'returns a hash with the access token' do
        expect(subject).to be_a(Hash)
        expect(subject.keys).to include('access_token')
        expect(subject.keys).to include('scope')
        expect(subject.keys).to include('expires_in')
        expect(subject.keys).to include('api_domain')
        expect(subject.keys).to include('token_type')
      end
    end
  end
end

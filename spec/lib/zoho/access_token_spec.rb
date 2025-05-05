# frozen_string_literal: true

require 'rails_helper'

module Zoho
  RSpec.describe AccessToken do
    describe '#generate' do
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

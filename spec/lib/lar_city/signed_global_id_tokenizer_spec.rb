# frozen_string_literal: true

require 'rails_helper'

module LarCity
  RSpec.describe SignedGlobalIdTokenizer, type: :model do
    describe '.encode' do
      # Expires in 2 hours
      let(:expires_in) { 60 * 60 * 2 }
      let(:purpose) { 'sharing' }

      it 'encodes a token' do
        resource = double
        options = {}
        options[:expires_in] = expires_in if expires_in.positive?
        options[:for] = purpose if purpose
        expect(resource).to receive(:to_signed_global_id).with(options)
        described_class.encode(resource, expires_in:, purpose:)
      end

      context 'for users' do
        let(:resource) { Fabricate(:user) }
        let(:token) { described_class.encode(resource) }

        it 'encodes the token' do
          expect(described_class.encode(resource)).not_to be_nil
        end
      end

      context 'for invoices' do
        let(:resource) { Fabricate(:invoice) }
        let(:token) { described_class.encode(resource) }

        it 'encodes the token' do
          expect(described_class.encode(resource)).not_to be_nil
        end
      end

      context 'for accounts' do
        let(:resource) { Fabricate(:account) }
        let(:token) { described_class.encode(resource) }

        it 'encodes the token' do
          expect(described_class.encode(resource)).not_to be_nil
        end
      end
    end

    describe '.decode' do
      context 'with includes' do
        it 'decodes a token' do
          token = double
          resource_class = double
          includes = [:account]
          options = { only: resource_class }
          options[:includes] = includes
          resource = double
          expect(GlobalID::Locator).to receive(:locate_signed).with(token, options).and_return(resource)
          expect(described_class.decode(token, resource_class, includes:)).to eq([resource, {}])
        end
      end

      context 'without includes' do
        it 'decodes a token' do
          token = double
          resource_class = double
          options = { only: resource_class }
          resource = double
          expect(GlobalID::Locator).to receive(:locate_signed).with(token, options).and_return(resource)
          expect(described_class.decode(token, resource_class)).to eq([resource, {}])
        end
      end

      context 'for users' do
        let(:resource) { Fabricate(:user) }

        subject { described_class.encode(resource) }

        it 'decodes the token' do
          expect(described_class.decode(subject, User)).to eq([resource, {}])
        end
      end

      context 'for invoices' do
        let(:resource) { Fabricate(:invoice) }

        subject { described_class.encode(resource) }

        it 'decodes the token' do
          expect(described_class.decode(subject, Invoice)).to eq([resource, {}])
        end
      end

      context 'for accounts' do
        let(:resource) { Fabricate(:account) }

        subject { described_class.encode(resource) }

        it 'decodes the token' do
          expect(described_class.decode(subject, Account)).to eq([resource, {}])
        end
      end
    end
  end
end

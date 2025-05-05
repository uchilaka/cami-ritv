# frozen_string_literal: true

require 'rails_helper'

module Zoho
  module API
    RSpec.describe Account do
      describe '.auth_endpoint_url' do
        subject { described_class.auth_endpoint_url }

        it 'returns the expected URL' do
          expect(subject).to eq('https://accounts.zoho.com')
        end

        it 'is idempotent' do
          expect(subject).to eq(described_class.auth_endpoint_url)
        end
      end

      describe '.resource_url' do
        let(:auth) { nil }

        subject { described_class.resource_url }

        it 'returns the expected accounts URL' do
          expect(subject).to eq('https://accounts.zoho.com')
        end

        it 'is idempotent' do
          expect(subject).to eq(described_class.resource_url)
        end

        context 'for auth requests' do
          let(:auth) { true }

          it 'returns the expected URL' do
            expect(described_class.resource_url(auth:)).to eq('https://accounts.zoho.com')
          end
        end

        context 'for non-auth requests' do
          let(:auth) { false }

          it 'returns the expected URL' do
            expect(described_class.resource_url(auth:)).to eq('https://www.zohoapis.com')
          end

          it 'returns the expected URL right after an auth request' do
            expect(described_class.resource_url(auth: true)).to eq('https://accounts.zoho.com')
            expect(described_class.resource_url(auth: false)).to eq('https://www.zohoapis.com')
          end
        end
      end

      describe '.base_url' do
        it { expect(described_class.base_url).to eq('https://www.zohoapis.com') }
      end

      describe '.fields_list_url' do
        let(:org_id) { described_class.send(:org_id) }

        it do
          expect(described_class.fields_list_url).to \
            eq("https://crm.zoho.com/crm/org#{org_id}/settings/api/modules/Accounts?step=FieldsList")
        end
      end

      describe '.upsert' do
        let(:phone_number) { Faker::PhoneNumber.cell_phone_in_e164 }
        let(:display_name) { Faker::Company.name }
        let(:email) { Faker::Internet.email }
        let(:website) { Faker::Internet.url(host: 'larcity.dev') }
        let(:metadata) { { website: } }
        let(:record) { Fabricate(:account, display_name:, email:, phone_number:) }
        let(:inserted_record) { subject.dig('data', 0) }
        let(:inserted_record_details) { inserted_record['details'] }

        # VCR configuration
        let(:cassette) { vcr_cassettes[:zoho] }
        # Comment out this declaration if you're working on updating cassettes
        let(:cassette_options) do
          cassette[:options]
            .deep_merge(
              match_requests_on: %i[method uri],
              record: :none
            )
        end
        # Un-comment this line if you're working on updating cassettes
        # let(:cassette_options) { cassette[:options] }

        around do |example|
          # Edit the cassette options for :zoho at config/vcr.yml
          VCR.use_cassette('zoho/upsert_accounts', cassette_options) { example.run }
        end
        # End VCR configuration

        subject { described_class.upsert(record) }

        context 'with valid attributes' do
          context 'and new record' do
            # Un-comment this line if you're working on updating cassettes
            # let(:cassette_options) { cassette[:options] }

            it 'returns a hash with the upserted record' do
              expect(subject).to be_a(Hash)
              expect(subject.keys).to include('data')
              expect(subject['data']).to be_a(Array)
              expect(subject['data'].size).to eq(1)
              expect(inserted_record['code']).to eq 'SUCCESS'
              expect(inserted_record['action']).to eq 'insert'
              expect(inserted_record['status']).to eq 'success'
              expect(inserted_record_details['id']).to be_present
            end
          end

          context 'and an existing record' do
            let(:phone_number) { '+2347129248348' }
            let(:display_name) { "Mae's Bakery Inc." }
            let(:website) { 'https://maes-bakes.com' }
            let(:email) { 'maes-bakes@gmail.com' }

            # Un-comment this line if you're working on updating cassettes
            # let(:cassette_options) { cassette[:options] }

            # How to use:
            # ===========
            # 1. Comment out the "Mock setup" section
            # 2. To generate a new cassette:
            #   - Uncomment the "VCR configuration" section
            #   - Delete the existing cassette file (at spec/fixtures/cassettes/zoho/upsert_accounts.yml)
            #   - Run the test
            # 3. To run a live request:
            #   - Comment out the "VCR configuration" section
            #   - Run the test
            # ===========

            # Mock setup
            # let(:access_token) { 'test_access_token' }
            # let(:response_body) do
            #   {
            #     'data' => [
            #       {
            #         'code' => 'SUCCESS',
            #         'details' => {
            #           'id' => SecureRandom.uuid
            #         },
            #         'message' => 'record added successfully',
            #         'status' => 'success',
            #         'action' => 'insert'
            #       }
            #     ]
            #   }
            # end
            # let(:response) { double('response', body: response_body) }
            #
            # before do
            #   allow(AccessToken).to receive(:generate).and_return('access_token' => access_token)
            #   allow(described_class).to receive(:connection).with(access_token:).and_return(double(post: response))
            # end
            # End mock setup

            it 'returns a hash with the upserted record' do
              expect(subject).to be_a(Hash)
              expect(subject.keys).to include('data')
              expect(subject['data']).to be_a(Array)
              expect(subject['data'].size).to eq(1)
              expect(inserted_record['code']).to eq 'SUCCESS'
              expect(inserted_record['action']).to eq 'insert'
              expect(inserted_record['status']).to eq 'success'
              expect(inserted_record_details['id']).to be_present
            end
          end
        end

        context 'with invalid attributes' do
          pending 'missing phone number'
          pending 'missing email'
        end
      end

      describe '.serverinfo' do
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

        subject { described_class.serverinfo }

        it 'returns a hash with the server info' do
          expect(subject).to be_a(Hash)
          expect(subject.keys).to include('data')
          expect(subject['data']).to be_a(Hash)
          expect(subject['data']['id']).to be_present
          expect(subject['data']['name']).to be_present
          expect(subject['data']['type']).to be_present
          expect(subject['data']['country']).to be_present
        end

        it 'is idempotent' do
          expect(subject).to eq(described_class.serverinfo)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe LarCity::CLI::DDNSCmd do
  let(:instance) { described_class.new }
  let(:access_token) { 'test_token' }
  let(:domain) { 'example.com' }
  let(:record_name) { '@' }
  let(:record_type) { 'A' }
  let(:ip_address) { '203.0.113.1' }
  let(:ttl) { 300 }

  before do
    # Stub environment variables
    allow(Rails.application.credentials).to \
      receive(:digitalocean).and_return(OpenStruct.new(access_token:))

    # Stub IP detection services
    stub_request(:get, 'https://api.ipify.org')
      .to_return(status: 200, body: ip_address, headers: {})

    # Stub DigitalOcean API endpoints
    stub_request(:get, %r{https://api.digitalocean.com/v2/domains/#{domain}/records})
      .to_return(status: 200, body: { domain_records: [] }.to_json, headers: { 'Content-Type' => 'application/json' })

    stub_request(:post, %r{https://api.digitalocean.com/v2/domains/#{domain}/records})
      .to_return(status: 201, body: { domain_record: { id: '12345' } }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#update' do
    let(:options) do
      {
        domain:,
        record: record_name,
        type: record_type,
        ttl:,
      }
    end

    before do
      # Stub the say method to prevent output during tests
      allow(instance).to receive(:say)
      allow(instance).to receive(:options).and_return(options)
    end

    it 'updates DNS record with current public IP' do
      expect(instance).to receive(:fetch_public_ip).and_return(ip_address)
      expect(instance).to receive(:update_dns_record).with(
        token: access_token,
        domain:,
        record_name:,
        record_type:,
        ip_address:,
        ttl:
      )

      instance.update
    end
  end

  describe '#fetch_public_ip' do
    before do
      # Stub the say method to prevent output during tests
      allow(instance).to receive(:say)
      allow(instance).to receive(:exit)

      # Stub all IP services to fail except the last one
      stub_request(:get, 'https://api.ipify.org')
        .to_raise(Faraday::ConnectionFailed.new('Connection failed'))

      stub_request(:get, 'https://ifconfig.me/ip')
        .to_return(status: 200, body: 'invalid-ip', headers: {})

      stub_request(:get, 'https://ipinfo.io/ip')
        .to_return(status: 200, body: ip_address, headers: {})
    end

    it 'tries multiple services until it gets a valid IP' do
      expect(instance.send(:fetch_public_ip)).to eq(ip_address)
    end

    context 'when all services fail' do
      before do
        stub_request(:get, 'https://ipinfo.io/ip')
          .to_raise(Faraday::ConnectionFailed.new('Connection failed'))
      end

      it 'exits with an error message' do
        expect(instance).to receive(:say).with('Error: Could not determine public IP address', :red)
        expect(instance).to receive(:exit).with(1)
        instance.send(:fetch_public_ip)
      end
    end
  end

  describe '#update_dns_record' do
    let(:existing_record) do
      {
        'id' => '12345',
        'type' => record_type,
        'name' => '',
        'data' => '192.0.2.1',
        'ttl' => 300,
      }
    end

    before do
      allow(instance).to receive(:say)
      allow(instance).to receive(:exit)
    end

    context 'when record exists' do
      before do
        stub_request(:get, %r{https://api.digitalocean.com/v2/domains/#{domain}/records})
          .to_return(status: 200, body: { domain_records: [existing_record] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        stub_request(:put, %r{https://api.digitalocean.com/v2/domains/#{domain}/records/\d+})
          .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'updates the existing record' do
        instance.send(:update_dns_record,
                      token: access_token,
                      domain:,
                      record_name:,
                      record_type:,
                      ip_address:,
                      ttl:)

        expect(a_request(:put, %r{/records/\d+})
          .with(
            body: {
              data: ip_address,
              ttl:,
            }.to_json
          )).to have_been_made
      end
    end

    context 'when record does not exist' do
      before do
        stub_request(:get, %r{https://api.digitalocean.com/v2/domains/#{domain}/records})
          .to_return(status: 200, body: { domain_records: [] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        stub_request(:post, %r{https://api.digitalocean.com/v2/domains/#{domain}/records})
          .to_return(status: 201, body: { domain_record: { id: '12345' } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates a new record' do
        instance.send(:update_dns_record,
                      token: access_token,
                      domain:,
                      record_name:,
                      record_type:,
                      ip_address:,
                      ttl:)

        expect(a_request(:post, %r{/records})
          .with(
            body: {
              type: record_type,
              name: nil, # Because record_name is '@'
              data: ip_address,
              ttl:,
            }.to_json
          )).to have_been_made
      end
    end

    context 'when API request fails' do
      before do
        stub_request(:get, %r{https://api.digitalocean.com/v2/domains/#{domain}/records})
          .to_return(status: 401, body: { message: 'Unauthorized' }.to_json,
                     headers: { 'Content-Type' => 'application/json' })
      end

      it 'shows an error message and exits' do
        expect(instance).to receive(:say).with(
          /Error communicating with DigitalOcean API:/,
          :red
        )
        expect(instance).to receive(:exit).with(1)

        instance.send(:update_dns_record,
                      token: 'invalid_token',
                      domain:,
                      record_name:,
                      record_type:,
                      ip_address:,
                      ttl:)
      end
    end
  end

  describe '#access_token' do
    context 'when token is provided in options' do
      before do
        allow(instance).to receive(:options).and_return(access_token: 'option_token')
      end

      it 'returns the token from options' do
        expect(instance.send(:access_token)).to eq('option_token')
      end
    end

    context 'when token is in environment' do
      before do
        allow(instance).to receive(:options).and_return({})
      end

      around do |example|
        with_modified_env(DIGITALOCEAN_ACCESS_TOKEN: 'env_token') do
          example.run
        end
      end

      it 'returns the token from environment' do
        expect(instance.send(:access_token)).to eq('env_token')
      end
    end

    context 'when token is in credentials' do
      before do
        allow(instance).to receive(:options).and_return({})
        allow(Rails.application.credentials).to \
          receive(:digitalocean).and_return(OpenStruct.new(access_token: 'credential_token'))
      end

      it 'returns the token from credentials' do
        expect(instance.send(:access_token)).to eq('credential_token')
      end
    end

    context 'when no token is available' do
      before do
        allow(instance).to receive(:options).and_return({})
        # allow(ENV).to receive(:fetch).with('DIGITALOCEAN_ACCESS_TOKEN', nil).and_return(nil)
        allow(Rails.application.credentials).to receive(:digitalocean).and_return(nil)
        allow(instance).to receive(:say_error).with(
          'DigitalOcean API token not provided. Use --token or set DIGITALOCEAN_TOKEN environment variable.'
        )
        allow(instance).to receive(:exit).with(1)
      end

      it 'shows an error and exits' do
        expect(instance).to receive(:say_error).with(
          'DigitalOcean API token not provided. Use --token or set DIGITALOCEAN_TOKEN environment variable.'
        )
        expect(instance).to receive(:exit).with(1)

        instance.send(:access_token)
      end
    end
  end
end

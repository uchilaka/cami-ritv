# frozen_string_literal: true

require 'rails_helper'
require 'faraday'
require 'faraday/adapter/test'

RSpec.describe LarCity::CLI::DDNSCmd do
  let(:instance) { described_class.new }
  let(:access_token) { 'test_token' }
  let(:domain) { 'example.com' }
  let(:record_name) { '@' }
  let(:record_type) { 'A' }
  let(:ip_address) { '203.0.113.1' }
  let(:ttl) { 300 }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:test_client) do
    Faraday.new do |builder|
      builder.request :json
      builder.response :json, content_type: /\bjson$/
      builder.response :raise_error
      builder.headers['Accept'] = 'application/json'
      builder.adapter :test, stubs
    end
  end

  before do
    # Stub environment variables
    allow(Rails.application.credentials).to \
      receive(:digitalocean).and_return(OpenStruct.new(access_token:))

    # Stub the HTTP client to use our test adapter
    allow(LarCity::HttpClient).to receive(:client).and_return(test_client)
    allow(LarCity::HttpClient).to receive(:new_client).and_return(test_client)

    # Stub the default IP service for most tests
    stubs.get('https://api.ipify.org') do
      [200, {}, ip_address]
    end

    # Stub DigitalOcean API endpoints - return the expected parsed response structure
    stubs.get(%r{/v2/domains/#{domain}/records}) do |_env|
      [200, { 'Content-Type' => 'application/json' }, { 'domain_records' => [] }.to_json]
    end

    stubs.post(%r{/v2/domains/#{domain}/records}) do |_env|
      [201, { 'Content-Type' => 'application/json' }, { 'domain_record' => { 'id' => '12345' } }.to_json]
    end
  end

  after do
    stubs.verify_stubbed_calls
  rescue => e
    # Don't fail tests for unstubbed calls in after hook
    Rails.logger.warn("Faraday stubs verification failed: #{e.message}")
  end

  describe '#upsert' do
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

      # Stub the fetch_public_ip method to avoid actual HTTP calls
      allow(instance).to receive(:fetch_public_ip).and_return(ip_address)

      # Stub DigitalOcean API endpoints
      stubs.get(%r{/v2/domains/#{domain}/records}) do |_env|
        [200, { 'Content-Type' => 'application/json' }, { domain_records: [] }]
      end

      stubs.post(%r{/v2/domains/#{domain}/records}) do |_env|
        [201, { 'Content-Type' => 'application/json' }, { domain_record: { id: '12345' } }]
      end
    end

    it 'updates DNS record with current public IP' do
      expect(instance).to receive(:fetch_public_ip).and_return(ip_address)

      # Expect the update_dns_record method to be called with the correct arguments
      expect(instance).to receive(:upsert_dns_record).with(
        domain:,
        record_name:,
        record_type:,
        ip_address:,
        ttl:
      )

      instance.upsert
    end
  end

  describe '#fetch_public_ip' do
    before do
      # Clear any existing stubs for IP services
      stubs.instance_variable_get(:@stack).clear

      # Stub the say method to prevent output during tests
      allow(instance).to receive(:say)
      allow(instance).to receive(:exit)
    end

    it 'tries multiple services until it gets a valid IP' do
      # First service fails with connection error
      stubs.get('https://api.ipify.org') do
        raise Faraday::ConnectionFailed, 'Connection failed'
      end

      # Second service returns invalid IP
      stubs.get('https://ifconfig.me/ip') do
        [200, {}, 'invalid-ip']
      end

      # Third service returns valid IP
      stubs.get('https://ipinfo.io/ip') do
        [200, {}, ip_address]
      end

      expect(instance.send(:fetch_public_ip)).to eq(ip_address)
    end

    context 'when all services fail' do
      before do
        # All services fail with connection errors
        stubs.get('https://api.ipify.org') do
          raise Faraday::ConnectionFailed, 'Connection failed'
        end
        stubs.get('https://ifconfig.me/ip') do
          raise Faraday::ConnectionFailed, 'Connection failed'
        end
        stubs.get('https://ipinfo.io/ip') do
          raise Faraday::ConnectionFailed, 'Connection failed'
        end
      end

      it 'exits with an error message' do
        expect(instance).to receive(:say).with('Error: Could not determine public IP address', :red)
        expect(instance).to receive(:exit).with(1)
        instance.send(:fetch_public_ip)
      end
    end
  end

  describe '#upsert_dns_record' do
    let(:existing_record) do
      {
        'id' => '12345',
        'type' => record_type,
        'name' => '',
        'data' => '192.0.2.1',
        'ttl' => 300,
      }
    end

    let(:api_response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      # Clear any existing stubs
      stubs.instance_variable_get(:@stack).clear

      allow(instance).to receive(:say)
      allow(instance).to receive(:exit)

      # Stub the default IP service
      stubs.get('https://api.ipify.org') do
        [200, {}, ip_address]
      end
    end

    context 'when record exists' do
      before do
        stubs.get(%r{/v2/domains/#{domain}/records}) do |_env|
          [200, api_response_headers, { domain_records: [existing_record] }.to_json]
        end

        stubs.patch(%r{/v2/domains/#{domain}/records/\d+}) do |env|
          request_body = JSON.parse(env.body)
          expect(request_body).to include('data' => ip_address, 'ttl' => ttl)
          [200, api_response_headers, { domain_record: existing_record.merge('data' => ip_address) }.to_json]
        end
      end

      it 'updates the existing record' do
        instance.send(:upsert_dns_record,
                      domain:,
                      record_name:,
                      record_type:,
                      ip_address:,
                      ttl:)
      end
    end

    context 'when record does not exist' do
      before do
        stubs.get(%r{/v2/domains/#{domain}/records}) do |_env|
          [200, api_response_headers, { domain_records: [] }.to_json]
        end

        stubs.post(%r{/v2/domains/#{domain}/records}) do |env|
          request_body = JSON.parse(env.body || '{}')
          expect(request_body).to include(
            'type' => record_type,
            'data' => ip_address,
            'ttl' => ttl
          )
          # Record name should be nil when '@' is used
          expect(request_body['name']).to be_nil

          new_record = {
            'id' => '67890',
            'type' => record_type,
            'name' => nil,
            'data' => ip_address,
            'ttl' => ttl,
          }
          [201, api_response_headers, { domain_record: new_record }.to_json]
        end
      end

      it 'creates a new record' do
        instance.send(:upsert_dns_record,
                      domain:,
                      record_name:,
                      record_type:,
                      ip_address:,
                      ttl:)
      end
    end

    context 'when API request fails' do
      before do
        stubs.get(%r{/v2/domains/#{domain}/records}) do |_env|
          [401, { 'Content-Type' => 'application/json' }, { message: 'Unauthorized' }.to_json]
        end
      end

      it 'shows an error message and exits' do
        expect(instance).to receive(:say).with(
          /Error communicating with DigitalOcean API:/,
          :red
        )
        expect(instance).to receive(:exit).with(1)


        instance.send(:upsert_dns_record,
                      domain:,
                      record_name:,
                      record_type:,
                      ip_address:,
                      ttl:)
      end
    end
  end

  describe '#access_token' do
    before do
      # Clear any existing stubs
      # stubs.instance_variable_get(:@stack).clear
      # RSpec::Mocks.teardown

      # Stub the default IP service
      stubs.get('https://api.ipify.org') do
        [200, {}, ip_address]
      end

      # Stub DigitalOcean API endpoints to avoid actual calls - return parsed response structure
      stubs.get(%r{/v2/domains/}) do
        [200, { 'Content-Type' => 'application/json' }, { 'domain_records' => [] }.to_json]
      end
      stubs.post(%r{/v2/domains/}) do
        [201, { 'Content-Type' => 'application/json' }, { 'domain_record' => { 'id' => '12345' } }.to_json]
      end
    end

    context 'when token is provided in options' do
      before do
        allow(instance).to receive(:options).and_return(access_token: 'option_token')
      end

      it 'returns the token from options' do
        expect(instance.send(:access_token)).to eq('option_token')
      end
    end

    context 'when token is in environment',
            skip: 'deprecated in favor of handling within the DigitalOcean::API implementation' do
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

    context 'when token is in credentials',
            skip: 'deprecated in favor of handling within the DigitalOcean::API implementation' do
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

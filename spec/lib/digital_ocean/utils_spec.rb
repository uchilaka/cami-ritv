# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalOcean::Utils do
  let(:mock_credentials) do
    ActiveSupport::EncryptedConfiguration.new(
      config_path: Rails.root.join('config/credentials/test.yml.enc'),
      key_path: Rails.root.join('config/credentials/test.key'),
      env_key: 'RAILS_MASTER_KEY',
      raise_if_missing_key: true
    )
  end

  before do
    # Clear memoized access token before each test
    described_class.instance_variable_set(:@access_token, nil)
    # Mock credentials to prevent actual credential access during tests
    allow(Rails.application).to receive(:credentials).and_return(mock_credentials)
  end

  describe '.access_token!' do
    subject(:access_token!) { described_class.access_token! }

    it { is_expected.to eq('mock-do-secret-access-token') }

    context 'when DO_ACCESS_TOKEN is set' do
      around do |example|
        with_modified_env(DO_ACCESS_TOKEN: 'mock-do-access-token') { example.run }
      end

      it { is_expected.to eq('mock-do-access-token') }
    end

    context 'when DIGITALOCEAN_ACCESS_TOKEN is set' do
      around do |example|
        with_modified_env(DIGITALOCEAN_ACCESS_TOKEN: 'mock-digitalocean-access-token') { example.run }
      end

      it { is_expected.to eq('mock-digitalocean-access-token') }
    end

    context 'when no token is set' do
      let(:mock_credentials) { ActiveSupport::OrderedOptions.new({}) }

      it 'raises an error' do
        expect { access_token! }.to raise_error(KeyError, ':digitalocean is blank')
      end
    end
  end

  describe '.app_id!' do
    subject(:app_id!) { described_class.app_id! }

    it { is_expected.to eq('mock-do-secret-app-id') }

    context 'when DO_APP_ID is set' do
      around do |example|
        with_modified_env(DO_APP_ID: 'mock-do-app-id') { example.run }
      end

      it { is_expected.to eq('mock-do-app-id') }
    end

    context 'when no app_id is set' do
      let(:mock_credentials) { ActiveSupport::OrderedOptions.new({}) }

      it 'raises an error' do
        expect { app_id! }.to raise_error(KeyError, ':digitalocean is blank')
      end
    end
  end
end

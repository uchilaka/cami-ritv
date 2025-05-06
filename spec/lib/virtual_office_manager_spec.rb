# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VirtualOfficeManager do
  describe '.default_entity' do
    subject { described_class.default_entity }

    it 'returns the default entity' do
      expect(subject).to eq Rails.application.credentials&.entities&.larcity
    end
  end

  describe '.entity_by_key' do
    subject { described_class.entity_by_key(entity_key) }

    context 'when entity_key is :larcity' do
      let(:entity_key) { :larcity }

      it 'returns the larcity entity' do
        expect(subject).to eq Rails.application.credentials&.entities&.larcity
      end
    end

    context 'when entity_key is :some_other_key' do
      let(:entity_key) { :some_other_key }
      let(:mock_entity) do
        Struct::Company.new(
          name: Faker::Company.name,
          email: Faker::Internet.email,
          tax_id: Faker::Company.ein
        )
      end

      before do
        allow(Rails.application.credentials&.entities).to \
          receive(:some_other_key) { mock_entity }
      end

      it 'returns the entity with the key :some_other_key' do
        expect(subject).to eq Rails.application.credentials&.entities&.some_other_key
      end
    end

    context 'when entity_key is nil' do
      let(:entity_key) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when there is no entity for the sent key in the config' do
      let(:entity_key) { :non_existent_key }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.default_url_options' do
    let(:mock_hostname) { 'accounts.larcity.test' }

    subject { described_class.default_url_options }

    around do |example|
      with_modified_env HOSTNAME: mock_hostname, PORT: '1234' do
        example.run
      end
    end

    context "when the hostname health check feature is disabled" do
      around do |example|
        Flipper.disable(:feat__hostname_health_check)
        example.run
      end

      context 'when the hostname is an NGINX proxy' do
        let(:mock_hostname) { 'accounts.larcity.ngrok.app' }

        it { expect(subject).to eq(host: mock_hostname) }
      end

      context 'when the hostname is not an NGINX proxy' do
        it { expect(subject).to eq(host: mock_hostname, port: ENV.fetch('PORT')) }
      end
    end

    context 'when the hostname health check feature is enabled' do
      before do
        allow(AppUtils).to receive(:healthy?).and_return(true)
      end

      around do |example|
        Flipper.enable(:feat__hostname_health_check)
        example.run
        Flipper.disable(:feat__hostname_health_check)
      end

      context 'when the hostname is an NGINX proxy' do
        let(:mock_hostname) { 'accounts.larcity.ngrok.app' }

        it 'checks the health of the hostname' do
          expect(AppUtils).to receive(:healthy?).with("https://#{mock_hostname}/up")
          subject
        end

        it { expect(subject).to eq(host: mock_hostname) }
      end

      context 'when the hostname is not an NGINX proxy' do
        it 'checks the health of the hostname' do
          expect(AppUtils).to receive(:healthy?).with("http://#{mock_hostname}/up")
          subject
        end

        it { expect(subject).to eq(host: mock_hostname, port: ENV.fetch('PORT')) }
      end
    end
  end
end

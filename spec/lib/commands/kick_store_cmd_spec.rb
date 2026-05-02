# frozen_string_literal: true

require 'rails_helper'
require 'lib/commands/kick_store_cmd'

RSpec.describe KickStoreCmd, type: :command_stack do
  let(:target) { 'primary' }
  let(:options) { { target: } }
  let(:instance) { described_class.new([], **options) }
  let(:mock_service_cmd) { instance_double(LarCity::CLI::ServicesCmd, invoke: true) }

  before do
    allow(instance).to receive(:say_info)
    allow(instance).to receive(:run)
    allow(Rails).to receive(:root).and_return(Pathname.new('/tmp/app'))
    allow(Rails::Command).to receive(:invoke)
    allow(LarCity::CLI::ServicesCmd).to receive(:new) { mock_service_cmd }
  end

  describe '#wait_for_database_service_health_check' do
    subject(:health_check) { instance.wait_for_database_service_health_check }

    before do
      allow(instance).to receive(:run).and_call_original
    end

    context 'when target is primary' do
      let(:target) { 'primary' }

      around do |example|
        with_modified_env(
          APP_DATABASE_HOST: '127.0.0.1',
          APP_DATABASE_NAME_PRIMARY: 'sails_test'
        ) do
          example.run
        end
      end

      it { is_expected.to include(healthy: true) }
    end

    context 'when target is crm', skip: 'FIXME' do
      let(:target) { 'crm' }

      around do |example|
        with_modified_env(
          APP_DATABASE_HOST: '127.0.0.1',
          APP_DATABASE_NAME_CRM: 'crm_test'
        ) do
          example.run
        end
      end

      it { is_expected.to include(healthy: true) }
    end
  end

  describe '#create_data_store_if_not_exists' do
    before { instance.create_data_store_if_not_exists }

    context 'when target is primary' do
      let(:target) { 'primary' }

      it { expect(Rails::Command).to receive(:invoke).with('db:create:primary') }
    end

    context 'when target is crm' do
      let(:target) { 'crm' }

      # This is because the CRM is configured to skip database tasks
      it { expect(Rails::Command).not_to receive(:invoke).with('db:create:crm') }
    end
  end

  describe '#apply_migrations' do
    before { instance.apply_migrations }

    context 'when target is primary' do
      let(:target) { 'primary' }

      it { expect(Rails::Command).to have_received(:invoke).with('db:migrate:primary') }
    end

    context 'when target is crm' do
      let(:target) { 'crm' }

      it { expect(Rails::Command).to have_received(:invoke).with('db:migrate:crm') }
    end
  end

  describe '#maybe_restore_database_from_backup' do
    shared_examples 'supported database target' do |target|
      let(:mock_restore_cmd) { instance_double(RestoreDb, invoke_all: true) }
      let(:target) { target }

      before { allow(RestoreDb).to receive(:new).and_return(mock_restore_cmd) }

      it "invokes RestoreDb for #{target}" do
        expect(RestoreDb).to receive(:new).with([], target:, latest_backup: true, verbose: false, dry_run: false)
        expect(mock_restore_cmd).to receive(:invoke_all)
        instance.maybe_restore_database_from_backup
      end
    end

    context 'for primary database' do
      it_should_behave_like 'supported database target', 'primary'
    end

    context 'for crm database' do
      it_should_behave_like 'supported database target', 'crm'
    end
  end
end

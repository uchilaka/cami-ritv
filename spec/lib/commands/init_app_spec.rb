# frozen_string_literal: true

require 'rails_helper'
require 'lib/commands/restore_db'

load_thor_command 'lib', 'commands', 'init_app'

RSpec.describe InitApp, type: :command_stack do
  let(:options) { {} }
  let(:instance) { described_class.new([], **options) }
  let(:mock_service_cmd) { instance_double(LarCity::CLI::ServicesCmd, invoke: true) }

  before do
    allow(instance).to receive(:say_info)
    allow(instance).to receive(:run)
    allow(Rails).to receive(:root).and_return(Pathname.new('/tmp/app'))
    allow(Rails::Command).to receive(:invoke)
    allow(LarCity::CLI::ServicesCmd).to receive(:new) { mock_service_cmd }
  end

  describe '#setup_paths' do
    it 'creates resource path if not exists' do
      allow(Dir).to receive(:exist?).and_return(false)
      expect(FileUtils).to receive(:mkdir_p)
      instance.setup_paths
    end

    it 'does not create path if exists' do
      allow(Dir).to receive(:exist?).and_return(true)
      expect(FileUtils).not_to receive(:mkdir_p)
      instance.setup_paths
    end
  end

  describe '#touch_keep_file_for_app_store_downloads' do
    before { allow(FileUtils).to receive(:touch) }

    it 'touches .keep file' do
      expect(FileUtils).to receive(:touch).with('/tmp/app/db/test/postgres/downloads/.keep')
      instance.touch_keep_file_for_app_store_downloads
    end
  end

  describe '#start_database_service' do
    it 'runs docker-compose up' do
      expect(instance).to receive(:run).with('docker-compose up', '--detach app-store')
      instance.start_database_service
    end
  end

  describe '#wait_for_database_service_health_check' do
    subject(:health_check) { instance.wait_for_database_service_health_check }

    before do
      allow(instance).to receive(:run).and_call_original
    end

    around do |example|
      with_modified_env(
        APP_DATABASE_HOST: '127.0.0.1',
        APP_DATABASE_NAME: 'sails_test'
      ) do
        example.run
      end
    end

    it { is_expected.to include(healthy: true) }
  end

  describe '#create_data_stores_if_not_exists' do
    it 'invokes db:create for primary and crm' do
      expect(Rails::Command).to receive(:invoke).with('db:create:primary')
      expect(Rails::Command).to receive(:invoke).with('db:create:crm')
      instance.create_data_stores_if_not_exists
    end
  end

  describe '#apply_migrations' do
    it 'invokes db:migrate for primary and crm' do
      expect(Rails::Command).to receive(:invoke).with('db:migrate:primary')
      expect(Rails::Command).to receive(:invoke).with('db:migrate:crm')
      instance.apply_migrations
    end
  end

  describe '#maybe_restore_primary_database_from_backup' do
    let(:mock_restore_cmd) { instance_double(RestoreDb, invoke_all: true) }

    before do
      allow(RestoreDb).to receive(:new).and_return(mock_restore_cmd)
    end

    it 'invokes RestoreDb for crm' do
      expect(RestoreDb).to receive(:new).with([], target: 'primary', latest_backup: true, verbose: false, dry_run: false)
      expect(mock_restore_cmd).to receive(:invoke_all)
      instance.restore_database_from_backup(target: 'primary')
    end
  end

  describe '#restore_database_from_backup' do
    shared_examples 'supported database target' do |target|
      let(:mock_restore_cmd) { instance_double(RestoreDb, invoke_all: true) }

      before { allow(RestoreDb).to receive(:new).and_return(mock_restore_cmd) }

      it "invokes RestoreDb for #{target}" do
        expect(RestoreDb).to receive(:new).with([], target:, latest_backup: true, verbose: false, dry_run: false)
        expect(mock_restore_cmd).to receive(:invoke_all)
        instance.restore_database_from_backup(target:)
      end
    end

    context 'for primary database' do
      it_should_behave_like 'supported database target', 'primary'
    end

    context 'for crm database' do
      it_should_behave_like 'supported database target', 'crm'
    end
  end

  describe '#start_all_services' do
    let(:mock_service_cmd) { instance_double(LarCity::CLI::ServicesCmd, invoke: true) }

    before do
      allow(LarCity::CLI::ServicesCmd).to receive(:new).and_return(mock_service_cmd)
    end

    it 'starts all services' do
      expect(mock_service_cmd).to receive(:invoke).with(:start, [], dry_run: false, verbose: false)
      instance.start_all_services
    end
  end

  describe '#app_store_resource_path' do
    it 'returns correct path' do
      expect(instance.app_store_resource_path.to_s).to eq('/tmp/app/db/test/postgres/downloads')
    end
  end
end

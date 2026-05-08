# frozen_string_literal: true

require 'rails_helper'
require 'lib/commands/restore_db'
require 'lib/commands/kick_store_cmd'

load_thor_command 'lib', 'commands', 'init_app'

RSpec.describe InitApp, type: :command_stack do
  let(:options) { {} }
  let(:instance) { described_class.new([], **options) }
  let(:mock_service_cmd) { instance_double(LarCity::CLI::ServicesCmd, invoke: true) }
  let(:mock_kick_store_cmd) { instance_double(KickStoreCmd, invoke_all: true) }

  before do
    allow(instance).to receive(:say_info)
    allow(instance).to receive(:run)
    allow(Rails).to receive(:root).and_return(Pathname.new('/tmp/app'))
    allow(Rails::Command).to receive(:invoke)
    allow(LarCity::CLI::ServicesCmd).to receive(:new) { mock_service_cmd }
    allow(KickStoreCmd).to receive(:new) { mock_kick_store_cmd }
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

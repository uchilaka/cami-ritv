# frozen_string_literal: true

require 'rails_helper'
require 'commands/lar_city/cli/services_cmd'

RSpec.describe LarCity::CLI::ServicesCmd do
  subject(:command) { described_class.new([], mock_options, {}) }

  let(:mock_options) { { 'dry_run' => true } }

  before do
    allow(command).to receive(:run)
    allow(command).to receive(:say)
    allow(command).to receive(:say_error)
    allow(command).to receive(:say_info)
    allow(command).to receive(:say_success)
    allow(command).to receive(:say_highlight)
    allow(command).to receive(:print_line_break)
  end

  describe '#daemonize' do
    before do
      allow(FileUtils).to receive(:chmod)
      allow(File).to receive(:write)
      allow(command).to receive(:config_file_exists?).and_return(false)
      allow(command).to receive(:config_file_from).and_return('com.larcity.cami.plist')
      allow(command).to receive(:config_file).and_return('/path/to/com.larcity.cami.plist')
      allow(ERB).to receive(:new).and_return(double(result: 'plist_config'))
      allow(File).to receive(:read).and_return('template')
    end

    context 'when in test environment' do
      before do
        allow(Rails.env).to receive(:test?).and_return(true)
      end

      context 'with force option' do
        let(:mock_options) { { 'dry_run' => true, 'force' => true } }

        it 'does not skip' do
          command.daemonize
          expect(command).not_to have_received(:say_error)
        end
      end

      context 'without force option' do
        let(:mock_options) { { 'dry_run' => true, 'force' => false } }

        it 'skips and says error' do
          command.daemonize
          expect(command).to have_received(:say_error).with('Skipping daemonize in test environment.')
        end
      end
    end

    context 'when config file exists' do
      let(:mock_options) { { 'dry_run' => true, 'force' => false } }

      it 'does not overwrite without force' do
        allow(command).to receive(:config_file_exists?).and_return(true)
        command.daemonize
        expect(File).not_to have_received(:write)
      end
    end
  end

  describe '#lookup' do
    context 'when no ports are configured' do
      it 'prints an error message' do
        allow(command).to receive(:configured_ports).and_return([])
        command.lookup
        expect(command).to have_received(:say) do |*args|
          expect(args).to eq(['No configured ports found. Please ensure your environment variables are set correctly.', :red])
        end
      end
    end
  end

  describe '#kill_process' do
    let(:mock_options) { { 'pid' => '12345' } }

    it 'kills the process with the given pid' do
      command.kill_process
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['kill -9', '12345'])
      end
    end
  end

  describe '#connect' do
    let(:mock_options) { { 'database' => true } }

    it 'connects to the app-store service for the database' do
      allow(command).to receive(:service_connect_command).and_return('psql command')
      command.connect
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['docker compose', 'exec', 'app-store', 'psql command'])
      end
    end
  end

  describe '#start' do
    let(:mock_options) { { 'profile' => 'all' } }

    it 'starts the services' do
      command.start
      expect(command).to have_received(:run).with(
        'docker compose', '--profile all', 'up --detach', '&&',
        'docker compose', '--profile all', 'logs --follow --since 5m'
      )
    end
  end

  describe '#info' do
    let(:mock_options) { { 'profile' => 'essential' } }

    it 'lists the services' do
      command.info
      expect(command).to have_received(:run).with('docker compose', '--profile essential', 'ps')
    end
  end

  describe 'command mapping' do
    it 'maps "list" to "info"' do
      expect(described_class.map['list']).to eq(:info)
    end
  end

  describe '#logs' do
    let(:mock_options) { { 'profile' => 'batteries-included' } }

    it 'shows the logs of the services' do
      command.logs
      expect(command).to have_received(:run).with('docker compose', '--profile batteries-included', 'logs --follow --since 5m')
    end
  end

  describe '#stop' do
    let(:mock_options) { { 'profile' => 'batteries-included' } }

    it 'stops the services' do
      command.stop
      expect(command).to have_received(:run).with('docker compose', '--profile batteries-included', 'stop')
    end
  end

  describe '#teardown' do
    context 'when no service is specified' do
      let(:mock_options) { { 'dry_run' => true, 'profile' => 'batteries-included', 'service' => [] } }

      it 'tears down all services' do
        command.teardown
        expect(command).to have_received(:run).with('docker compose', '--profile batteries-included', 'down --remove-orphans --volumes')
      end
    end

    shared_examples 'teardown logic for services' do |*service_keys|
      let(:mock_options) { { 'dry_run' => true, 'service' => service_keys } }

      service_keys.each do |service|
        it "tears down the #{service} service" do
          command.teardown
          expect(command).to have_received(:run).with('docker compose stop', service, inline: true)
          expect(command).to have_received(:run).with('docker compose rm', '--force', '--volumes', service, inline: true)
        end
      end
    end

    context 'when a service is specified' do
      it_behaves_like 'teardown logic for services', 'web'
    end

    context 'when multiple services are specified' do
      it_behaves_like 'teardown logic for services', 'web', 'worker'
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'commands/lar_city/cli/services_cmd'

RSpec.describe LarCity::CLI::ServicesCmd do
  subject(:command) { described_class.new }

  let(:mock_options) { { dry_run: true } }

  before do
    allow(command).to receive(:run)
    allow(command).to receive(:say)
    allow(command).to receive(:say_error)
    allow(command).to receive(:say_info)
    allow(command).to receive(:say_success)
    allow(command).to receive(:say_highlight)
    allow(command).to receive(:print_line_break)
    allow(command).to receive(:options).and_return(mock_options)
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
      context 'with force option' do
        let(:mock_options) { { dry_run: true, force: true } }

        before do
          allow(command).to receive(:options).and_return(mock_options)
          command.daemonize
        end

        it { expect(command).not_to have_received(:say_error) }
      end

      context 'without force option' do
        before do
          allow(command).to receive(:options).and_return({ dry_run: true })
          command.daemonize
        end

        it { expect(command).to have_received(:say_error).with('Skipping daemonize in test environment.') }
      end
    end

    context 'when config file exists' do
      it 'does not overwrite without force' do
        allow(command).to receive(:config_file_exists?).and_return(true)
        allow(command).to receive(:options).and_return({ force: false })
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
    it 'kills the process with the given pid' do
      allow(command).to receive(:options).and_return({ pid: '12345' })
      command.kill_process
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['kill -9', '12345'])
      end
    end
  end

  describe '#connect' do
    it 'connects to the app-store service for the database' do
      allow(command).to receive(:options).and_return({ database: true })
      allow(command).to receive(:service_connect_command).and_return('psql command')
      command.connect
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['docker compose', 'exec', 'app-store', 'psql command'])
      end
    end
  end

  describe '#start' do
    it 'starts the services' do
      allow(command).to receive(:options).and_return({ profile: 'batteries-included' })
      command.start
      expect(command).to have_received(:run) do |*args|
        expect(args).to \
          eq(
            [
              'docker compose', '--profile batteries-included', 'up --detach', '&&',
              'docker compose', '--profile batteries-included', 'logs --follow --since 5m',
            ]
          )
      end
    end
  end

  describe '#info' do
    it 'lists the services' do
      allow(command).to receive(:options).and_return({ profile: 'batteries-included' })
      command.info
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['docker compose', '--profile batteries-included', 'ps'])
      end
    end
  end

  describe '#logs' do
    it 'shows the logs of the services' do
      allow(command).to receive(:options).and_return({ profile: 'batteries-included' })
      command.logs
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['docker compose', '--profile batteries-included', 'logs --follow --since 5m'])
      end
    end
  end

  describe '#stop' do
    it 'stops the services' do
      allow(command).to receive(:options).and_return({ profile: 'batteries-included' })
      command.stop
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['docker compose', '--profile batteries-included', 'stop'])
      end
    end
  end

  describe '#teardown' do
    before { command.teardown }

    context 'when no service is specified' do
      let(:mock_options) { { dry_run: true, profile: 'batteries-included', service: [] } }

      it 'tears down all services' do
        expect(command).to have_received(:run) do |*args|
          expect(args).to eq(['docker compose', '--profile batteries-included', 'down --remove-orphans --volumes'])
        end
      end
    end

    shared_examples 'teardown logic for services' do |*service_keys|
      let(:mock_options) { { dry_run: true, service: service_keys } }

      service_keys.each do |service|
        it "tears down the #{service} service" do
          [
            ['docker compose stop', service, inline: true],
            ['docker compose rm', '--force', '--volumes', service, inline: true],
          ].each do |expected_args|
            expect(command).to have_received(:run).with(*expected_args)
          end
        end
      end
    end

    context 'when a service is specified' do
      let(:mock_options) { { dry_run: true, service: %w[web] } }

      it_behaves_like 'teardown logic for services', 'web'
    end

    context 'when multiple services are specified' do
      let(:mock_options) { { dry_run: true, service: %w[web worker] } }

      it_behaves_like 'teardown logic for services', 'web', 'worker'
    end
  end
end

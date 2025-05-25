# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LarCity::CLI::TunnelCmd, type: :thor, devtool: true, skip_in_ci: true do
  let(:tunnel_cmd) { described_class.new }

  describe '#init' do
    before do
      allow(tunnel_cmd).to receive(:run)
      allow(File).to receive(:exist?).with(anything).and_call_original
    end

    context 'when in test environment' do
      it 'skips initialization' do
        expect(tunnel_cmd).to receive(:say).with('Skipping initialization of ngrok config in test environment.', anything)
        tunnel_cmd.init
      end
    end

    context 'when not in test environment' do
      context 'when ngrok config does not exist' do
        before do
          allow(Rails.env).to receive(:test?).and_return(false)
          allow(tunnel_cmd).to receive(:config_file_exists?).with(name: 'ngrok') { false }
          allow(File).to receive(:exist?).with(%r{/config/ngrok-via-docker.yml.erb$}).and_return(true)
          allow(File).to receive(:exist?).with(%r{/config/ngrok.yml.erb$}).and_return(true)
          allow(File).to receive(:exist?).with(%r{/config/ngrok(-via-docker)?.yml$}) { false }
          allow(ERB).to receive_message_chain(:new, :result).and_return('processed yaml content')
          allow(File).to receive(:write)
        end

        after do
          allow(ERB).to receive(:new).and_call_original
          allow(File).to receive(:write).and_call_original
          allow(Rails.env).to receive(:test?).and_call_original
        end

        it 'emits the config/ngrok.yml file from the ERB template' do
          output_msg_match = %r{Writing ngrok config to (.*)/config/ngrok.yml}
          expect { tunnel_cmd.invoke(:init) }.to output(output_msg_match).to_stdout
          expect(File).to have_received(:write).with(%r{/config/ngrok.yml$}, 'processed yaml content')
        end

        it 'emits the config/ngrok-via-docker.yml file from the ERB template' do
          output_msg_match = %r{Writing ngrok config to (.*)/config/ngrok-via-docker.yml}
          expect { tunnel_cmd.invoke(:init) }.to output(output_msg_match).to_stdout
          expect(File).to have_received(:write).with(%r{/config/ngrok-via-docker.yml$}, 'processed yaml content')
        end
      end
    end
  end

  describe '#open_all' do
    context 'when NGROK_AUTH_TOKEN is not set' do
      around do |example|
        with_modified_env(NGROK_AUTH_TOKEN: nil) { example.run }
      end

      it 'prints an error message' do
        expect { tunnel_cmd.invoke(:open_all) }.to output(/No ngrok auth token found/).to_stdout
      end
    end

    context 'when NGROK_AUTH_TOKEN is set', skip: 'wip: all tests failing as at last check' do
      before do
        allow(File).to receive(:exist?).with(%r{/.ngrok2/ngrok.yml$}).and_return(false)
        allow(File).to receive(:exist?).with(%r{/config/ngrok-via-docker.yml.erb$}).and_return(true)
        allow(File).to receive(:exist?).with(%r{/config/ngrok.yml.erb$}).and_return(true)
        allow(File).to receive(:exist?).with(%r{/config/ngrok(-via-docker)?.yml$}) { false }
        allow(tunnel_cmd).to receive(:run)
      end

      after do
        allow(File).to receive(:exist?).and_call_original
      end

      around do |example|
        with_modified_env(NGROK_AUTH_TOKEN: 'mock_ngrok_auth_token') { example.run }
      end

      shared_examples 'ngrok starts with the expected command' do |expected_command|
        it do
          tunnel_cmd.invoke(:open_all, [], dry_run: true)
          expect(tunnel_cmd).to have_received(:run).with(expected_command)
        end
      end

      context 'and the detected OS is NOT Windows or Linux' do
        before do
          allow(tunnel_cmd).to receive(:friendly_os_name).and_return(:macos)
        end

        it do
          tunnel_cmd.invoke(:open_all, [], dry_run: true)
          expect(tunnel_cmd).to \
            have_received(:run).with(
              'ngrok start --all', "--config=#{Rails.root}/config/ngrok.yml"
            )
        end
      end

      context 'and the detected OS is Windows' do
        before do
          allow(tunnel_cmd).to receive(:friendly_os_name).and_return(:windows)
        end

        it_should_behave_like 'ngrok starts with the expected command', 'docker compose up tunnel'
      end

      context 'when the detected OS is Linux' do
        before do
          allow(tunnel_cmd).to receive(:friendly_os_name).and_return(:linux)
        end

        it_should_behave_like 'ngrok starts with the expected command', 'docker compose up tunnel'
      end
    end
  end
end

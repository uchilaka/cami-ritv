# frozen_string_literal: true

require 'rails_helper'
require 'commands/lar_city/cli/services_cmd'

module LarCity
  module CLI
    describe ServicesCmd, type: :command do
      subject(:command) { described_class.new }

      describe '#lookup' do
        context 'when no configured ports are present' do
          before do
            allow(command).to receive(:configured_ports).and_return([])
          end

          it 'notifies the user about missing ports' do
            expect { command.lookup }.to \
              output(/No configured ports found. Please ensure your environment variables are set correctly/).to_stdout
          end
        end

        context 'when configured ports are present' do
          let(:ports) { [3036, 16_006] }
          before do
            allow(command).to receive(:configured_ports).and_return(ports)
          end

          it 'builds a regex for the configured ports' do
            expect(Regexp).to receive(:union).with(ports.map { |port| ":#{port}\\b" })
            command.lookup
          end
        end
      end

      describe '#daemonize', skip: 'TODO: regex matching for outputs not working out yet' do
        subject(:command) { described_class.new(cmd_args, **options) }

        let(:cmd_args) { [] }
        let(:options) { { dry_run: true, force: true } }
        let(:expected_plist_config_path) { Rails.root.join('config', 'com.larcity.cami.plist').to_s }
        let(:expected_plist_filename) { File.basename(expected_plist_config_path) }
        let(:expected_symlink_cmd) do
          "ln -svf #{expected_plist_config_path} /Library/LaunchDaemons/#{expected_plist_filename}"
        end
        let(:expected_load_cmd) { "launchctl load -w /Library/LaunchDaemons/#{expected_plist_filename}" }
        let(:expected_symlink_output) { "Executing (dry-run): sudo #{expected_symlink_cmd}" }
        let(:expected_load_output) { "Executing (dry-run): sudo #{expected_load_cmd}" }
        let(:expected_output) do
          <<~OUTPUT
            #{expected_symlink_output}
            #{expected_load_output}
          OUTPUT
        end

        it { expect { command.daemonize }.to output(/#{expected_output}/).to_stdout }
      end
    end
  end
end

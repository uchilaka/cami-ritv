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
    end
  end
end

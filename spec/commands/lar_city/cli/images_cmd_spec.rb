# frozen_string_literal: true

require 'rails_helper'
# require 'lar_city/cli/utils'
require 'commands/lar_city/cli/images_cmd'

module LarCity
  module CLI
    RSpec.describe ImagesCmd, type: :command do
      subject(:command) { described_class.new }

      let(:service_name) { 'worker' }
      let(:dry_run) { true }
      let(:docker_compose_config) do
        {
          'services' => {
            'web' => { 'build' => '.' },
            'worker' => { 'build' => '.' }
          }
        }
      end
      let(:build_output) { "Image #{service_name} built" }
      let(:push_output) { "naming to registry.fly.io/cami-lab-#{service_name}:latest" }

      before do
        allow(command).to receive(:docker_compose_config).and_return(docker_compose_config)
        allow(command).to receive(:run).and_return(build_output)
      end

      describe 'build' do
        context 'when building an image' do
          it 'succeeds and reports the image_id' do
            expect(command).to receive(:run)
                                 .with('docker compose build', service_name, '--dry-run')
                                 .and_return(build_output)
            command.invoke(:build, [], { service: service_name, dry_run: })
            expect(command.result).to eq(build_output)
          end
        end

        context 'when building and pushing an image' do
          it 'succeeds and reports the image_id from push output' do
            expect(command).to receive(:run)
                                 .with('docker compose build', service_name, '--dry-run', '--push')
                                 .and_return(push_output)
            command.invoke(:build, [], { service: service_name, dry_run:, push: true })
            expect(command.result).to eq(push_output)
          end
        end

        context 'with an unsupported service' do
          let(:unsupported_service) { 'db' }
          it 'raises an error' do
            expect do
              command.invoke(:build, [], { service: unsupported_service, dry_run: })
            end.to raise_error(LarCity::CLI::Errors::Unsupported)
          end
        end
      end
    end
  end
end



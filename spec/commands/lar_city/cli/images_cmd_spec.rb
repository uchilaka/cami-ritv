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
      # let(:docker_compose_config) do
      #   {
      #     'services' => {
      #       'web' => { 'build' => '.' },
      #       'worker' => { 'build' => '.' }
      #     }
      #   }
      # end
      let(:build_output) { %r{Image #{service_name} Built} }
      let(:push_output) { %r{naming to registry\.fly\.io/cami-test-#{service_name}\:latest} }

      before do
        # allow(command).to receive(:docker_compose_config).and_return(docker_compose_config)
      end

      around do |example|
        with_modified_env(FLY_APP_NAME_PREFIX: 'cami-test') { example.run }
      end

      describe 'build' do
        context 'when building an image' do
          let(:build_args) { { service: service_name, dry_run: } }

          it 'succeeds and reports the image_id' do
            expect { command.invoke(:build, [], **build_args) }.to \
              output(build_output).to_stdout_from_any_process
          end

          it 'reports the image_id' do
            expect { command.invoke(:build, [], **build_args) }.to \
              output(push_output).to_stdout_from_any_process
          end
        end

        context 'when building and pushing an image' do
          let(:build_args) { { service: service_name, dry_run:, push: true } }

          it 'succeeds and reports the image_id' do
            expect { command.invoke(:build, [], **build_args) }.to \
              output(build_output).to_stdout_from_any_process
          end

          it 'reports the image_id' do
            expect { command.invoke(:build, [], **build_args) }.to \
              output(push_output).to_stdout_from_any_process
          end
        end

        context 'with an unsupported service' do
          let(:unsupported_service) { 'db' }
          let(:build_args) { { service: unsupported_service, dry_run: } }

          it 'raises an error' do
            expect do
              command.invoke(:build, [], **build_args)
            end.to raise_error(LarCity::Errors::Unsupported)
          end
        end
      end
    end
  end
end



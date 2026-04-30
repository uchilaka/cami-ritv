# frozen_string_literal: true

require 'rails_helper'
require 'commands/lar_city/cli/images_cmd'

module LarCity
  module CLI
    RSpec.describe ImagesCmd, type: :command do
      subject(:command) { described_class.new }

      let(:service_name) { 'worker' }
      let(:dry_run) { true }
      let(:build_output) { %r{Image (.*) Built} }
      let(:push_output) { %r{naming to registry\.test/accounts-#{service_name}:latest} }

      around do |example|
        with_modified_env(CONTAINER_REGISTRY_HOST: 'registry.test', CONTAINER_NAME_PREFIX: 'accounts') { example.run }
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

        context 'with an unsupported service',
                skip: 'TODO: this test with a "TeamCity Rake Runner Plugin isn\'t compatible with this RSpec version" error message' do
          let(:unsupported_service) { 'redis' }
          let(:unsupported_message) { %r{The specified service \[#{unsupported_service}\] is not supported} }
          let(:build_args) { { service: unsupported_service, dry_run: } }

          it 'raises the expected error' do
            expect do
              command.invoke(:build, [], **build_args)
            end.to raise_error(SystemExit)
          end

          it 'outputs the expected message' do
            expect { command.invoke(:build, [], **build_args) }.to \
              output(unsupported_message).to_stdout_from_any_process
          end
        end
      end
    end
  end
end



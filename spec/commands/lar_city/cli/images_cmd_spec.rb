# frozen_string_literal: true

require 'rails_helper'
require 'commands/lar_city/cli/images_cmd'

module LarCity
  module CLI
    RSpec.describe ImagesCmd, type: :command, skip_in_ci: true do
      subject(:command) { described_class.new }

      let(:service_name) { 'web' }
      let(:dry_run) { true }
      let(:build_output) { %r{Image (.*) Built} }
      let(:push_output) { %r{naming to larcity/accounts-#{service_name}\s} }

      around do |example|
        with_modified_env(
          CONTAINER_REGISTRY_HOST: 'registry.test',
          CONTAINER_NAME_PREFIX: 'accounts'
        ) { example.run }
      end

      describe 'build' do
        context 'when building an image' do
          let(:build_args) { { service: service_name, dry_run: } }

          it do
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

          it do
            expect { command.invoke(:build, [], **build_args) }.to \
              output(build_output).to_stdout_from_any_process
          end

          it 'reports the image_id' do
            expect { command.invoke(:build, [], **build_args) }.to \
              output(push_output).to_stdout_from_any_process
          end
        end

        context 'when building an image with override composition' do
          let(:build_args) { { service: service_name, dry_run: } }
          let(:push_output) { %r{naming to registry\.test/accounts-#{service_name}:latest} }
          let(:override_compose_file_path) { Rails.root.join('docker-compose.override.yml').to_s }
          let(:override_content) do
            <<~YAML
              version: '3.8'
              services:
                web:
                  image: ${CONTAINER_REGISTRY_HOST}/${CONTAINER_NAME_PREFIX}-web:latest
                worker:
                  image: ${CONTAINER_REGISTRY_HOST}/${CONTAINER_NAME_PREFIX}-worker:latest
            YAML
          end

          around do |example|
            if File.exist?(override_compose_file_path)
              original_content = File.read(override_compose_file_path)
              begin
                File.write(override_compose_file_path, override_content)
                example.run
              ensure
                File.write(override_compose_file_path, original_content)
              end
            else
              begin
                File.write(override_compose_file_path, override_content)
                example.run
              ensure
                FileUtils.rm(override_compose_file_path)
              end
            end
          end

          it do
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


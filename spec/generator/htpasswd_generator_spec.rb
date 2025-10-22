# frozen_string_literal: true

require 'rails_helper'
require 'lib/generators/htpasswd/htpasswd_generator'

RSpec.describe HtpasswdGenerator, type: :generator do
  let(:generator) { described_class.new }

  before do
    allow(LarCity::CLI::Utils::Ask).to \
      receive(:prompt_for_auth_credentials)
        .and_return({ username: 'testuser', password: 'testpassword' })
    allow(generator).to receive(:run)
    allow(FileUtils).to receive(:mkdir_p)
  end

  describe '#prompt_for_credentials' do
    it 'prompts for and assigns credentials' do
      generator.prompt_for_credentials
      expect(generator.username).to eq('testuser')
      expect(generator.password).to eq('testpassword')
    end
  end

  describe '#show_credentials' do
    let(:expected_output) do
      <<~OUTPUT
        Generated HTTP basic auth credentials: {username: "testuser", password: "tes******ord"}
      OUTPUT
    end

    before do
      generator.username = 'testuser'
      generator.password = 'testpassword'
    end

    it 'shows the credentials' do
      expect { generator.show_credentials }.to output(expected_output).to_stdout
    end
  end

  describe '#setup_auth_config_directory' do
    let(:auth_dir) { Rails.root.join('config/httpd/auth').to_s }

    context 'when directory exists' do
      before do
        allow(Dir).to receive(:exist?).with(auth_dir).and_return(true)
      end

      it 'says directory exists' do
        expect(generator).to receive(:say_status).with(:exist, "directory: #{auth_dir}")
        generator.setup_auth_config_directory
      end
    end

    context 'when directory does not exist' do
      before do
        allow(Dir).to receive(:exist?).with(auth_dir).and_return(false)
      end

      context 'when dry run' do
        it 'says it would have created directory' do
          expect(generator).to receive(:say_highlight).with("Dry-run: Would have created directory #{auth_dir}")
          generator.setup_auth_config_directory
        end
      end

      context 'when not dry run' do
        it 'creates directory' do
          expect(generator).to receive(:say_status).with(:create, "directory: #{auth_dir}")
          expect(FileUtils).to receive(:mkdir_p).with(auth_dir)
          generator.setup_auth_config_directory
        end
      end
    end
  end

  describe '#codegen' do
    before do
      generator.username = 'testuser'
      generator.password = 'testpassword'
      generator.instance_variable_set(:@auth_dir_mount_source, '/path/to/auth')
    end

    context 'when on windows' do
      before do
        allow(generator).to receive(:windows?).and_return(true)
      end

      it 'runs the correct docker command' do
        expected_cmd = [
          'docker run',
          '--rm',
          '--entrypoint htpasswd',
          '--mount type=volume,source=/path/to/auth,target=/auth',
          'httpd:2', '-Bbn', 'testuser', 'testpassword',
          '| Set-Content -Encoding ASCII auth/htpasswd',
        ]
        expect(generator).to receive(:run).with(*expected_cmd, inline: true)
        generator.codegen
      end
    end

    context 'when not on windows' do
      before do
        allow(generator).to receive(:windows?).and_return(false)
      end

      it 'runs the correct docker command' do
        expected_cmd = [
          'docker run',
          '--rm',
          '--entrypoint htpasswd',
          '--mount type=volume,source=/path/to/auth,target=/auth',
          'httpd:2', '-Bbn', 'testuser', 'testpassword',
          '> auth/htpasswd',
        ]
        expect(generator).to receive(:run).with(*expected_cmd, inline: true)
        generator.codegen
      end
    end
  end
end

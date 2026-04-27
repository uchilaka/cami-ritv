# frozen_string_literal: true

require 'rails_helper'

load_lib_script 'commands', 'env_setup_cmd', ext: 'rb'

RSpec.describe EnvSetupCmd, type: :thor do
  let(:options) { {} }
  let(:command_args) { [] }
  let(:command) { described_class.new(command_args, options) }

  before do
    allow(command).to receive(:detected_environment).and_return('lab')
    allow(command).to receive(:vault_share_id).and_return('vault-share-id')
    allow(command).to receive(:source_item_id).and_return('source-item-id')
    allow(command).to receive(:shared_source_item_id).and_return('shared-source-item-id')

    # Mocking File operations to avoid actual file system changes
    allow(File).to receive(:write)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:exist?).and_return(false)
    
    # Silence output
    allow(command).to receive(:say_info)
    allow(command).to receive(:say_success)
    allow(command).to receive(:say_error)
    allow(command).to receive(:say_debug)
    allow(command).to receive(:say_warning)
    
    # Stub vault connection
    allow(command).to receive(:require_authenticated_vault_connection!)
  end

  describe '#debug_template_file_content' do
    it 'outputs the template content to debug' do
      expect(command).to receive(:say_debug).with(/ENV Template Content/)
      command.debug_template_file_content
    end
  end

  describe '#write_template_file' do
    it 'attempts to write the template file' do
      expect(File).to receive(:write).with(command.send(:template_file_path), any_args).and_return(100)
      command.write_template_file
    end

    it 'logs an error if writing fails' do
      allow(File).to receive(:write).and_return(0)
      expect(command).to receive(:say_error).with(/Failed to write/)
      command.write_template_file
    end

    context 'when dry_run is enabled' do
      let(:options) { { dry_run: true } }

      it 'does not write the file' do
        expect(File).not_to receive(:write)
        command.write_template_file
      end
    end
  end

  describe '#provision_env_file' do
    before do
      allow(command).to receive(:run).and_return('injected successfully')
      allow(File).to receive(:exist?).with(command.send(:template_file_path)).and_return(true)
    end

    it 'provisions the .env file from template' do
      expect(command).to receive(:run).with('pass-cli inject', any_args).and_return('injected successfully')
      command.provision_env_file
    end

    it 'logs an error if authentication is required' do
      allow(command).to receive(:run).and_return('requires an authenticated client')
      expect(command).to receive(:say_error).with(/Authentication required/)
      command.provision_env_file
    end

    it 'logs an error if provisioning fails' do
      allow(command).to receive(:run).and_return('some error')
      expect(command).to receive(:say_error).with(/Failed to provision/)
      command.provision_env_file
    end

    context 'when source is cli' do
      let(:options) { { source: ['cli'] } }

      it 'provisions the .env file directly' do
        expect(File).to receive(:write).with(command.send(:output_file_path), any_args).and_return(100)
        command.provision_env_file
      end
    end
  end

  describe '#template_content' do
    subject(:content) { command.send(:template_content) }

    context 'when environment-specific template exists' do
      before do
        allow(File).to receive(:exist?).with(command.send(:dotenv_template_file_path)).and_return(true)
        allow(File).to receive(:read).with(command.send(:dotenv_template_file_path)).and_return('ERB content <%= detected_environment %>')
      end

      it 'renders the ERB template' do
        expect(content).to include('ERB content lab')
      end
    end

    context 'when environment-specific template does not exist' do
      it 'builds a default template' do
        expect(content).to include('export NODE_ENV=lab')
        expect(content).to include('export GITCRYPT_KEY_FILE')
      end
    end
  end
end

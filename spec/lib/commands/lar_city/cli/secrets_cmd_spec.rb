# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LarCity::CLI::SecretsCmd, type: :thor, devtool: true, skip_in_ci: true do
  let(:secrets_cmd) { described_class.new }

  describe '#gpg_keys' do
    it 'runs the gpg list secret keys command' do
      expect(secrets_cmd).to receive(:run).with('gpg --list-secret-keys --keyid-format LONG')
      secrets_cmd.gpg_keys
    end
  end

  describe '#edit' do
    before do
      allow(secrets_cmd).to receive(:run)
    end

    context 'with default editor' do
      it 'uses rubymine as the default editor' do
        expect(secrets_cmd).to receive(:run).with('rubymine --wait config/credentials.yml.enc')
        secrets_cmd.invoke(:edit)
      end
    end

    context 'with nano as editor' do
      it 'uses nano when specified' do
        expect(secrets_cmd).to receive(:run).with('nano config/credentials.yml.enc')
        secrets_cmd.invoke(:edit, [], editor: 'nano')
      end
    end

    context 'with code as editor' do
      it 'uses code when specified' do
        expect(secrets_cmd).to receive(:run).with('code config/credentials.yml.enc')
        secrets_cmd.invoke(:edit, [], editor: 'code')
      end
    end

    context 'with invalid editor' do
      it 'raises an error for invalid editor' do
        expect {
          secrets_cmd.invoke(:edit, [], editor: 'vim')
        }.to raise_error(Thor::MalformattedArgumentError)
      end
    end
  end
end


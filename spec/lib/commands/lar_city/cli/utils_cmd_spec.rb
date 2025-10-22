# frozen_string_literal: true

require 'rails_helper'
require 'lib/commands/lar_city/cli/utils_cmd'

RSpec.describe LarCity::CLI::UtilsCmd, type: :command do
  subject(:command) { described_class.new }

  let(:domain) { 'accounts.larcity.test' }

  describe '#kick_nginx_config' do
    let(:nginx_config_file) { "#{Rails.root}/.nginx/test/conf.d/servers.conf" }
    let(:nginx_config_symlink) { '/opt/homebrew/etc/nginx/servers/cami.conf' }
    let(:nginx_ssl_artifacts_path) { "#{Rails.root}/.nginx/test/ssl" }
    let(:nginx_ssl_artifacts_symlink) { '/opt/homebrew/etc/nginx/certs' }
    let(:artifact_path) { "#{nginx_ssl_artifacts_path}/#{domain}.pem" }

    before do
      allow(Rails.env).to receive(:test?).and_return(false)
      allow(File).to receive(:exist?).with(nginx_config_file).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:ln_sf)
      allow(Dir).to receive(:[]).with("#{nginx_ssl_artifacts_path}/*.pem").and_return([artifact_path])
      allow(command).to receive(:run)
    end

    it 'symlinks SSL artifacts using the correct basename' do
      expected_symlink_target = "#{nginx_ssl_artifacts_symlink}/#{File.basename(artifact_path)}"
      expect(FileUtils).to receive(:ln_sf).with(artifact_path, expected_symlink_target, verbose: false, noop: false)
      command.kick_nginx_config
    end
  end

  describe '#setup_nginx_certs' do
    let(:tailscale_certs_path) { "#{Dir.home}/Library/Containers/io.tailscale.ipn.macos/Data" }
    let(:nginx_certs_path) { '/opt/homebrew/etc/nginx/certs' }
    let(:crt_file) { "#{tailscale_certs_path}/#{domain}.crt" }
    let(:target_crt_file) { "#{nginx_certs_path}/#{domain}.crt" }
    let(:key_file) { "#{tailscale_certs_path}/#{domain}.key" }
    let(:target_key_file) { "#{nginx_certs_path}/#{domain}.key" }

    before do
      allow(command).to receive(:tailscale_certs_path).and_return(tailscale_certs_path)
      allow(command).to receive(:nginx_certs_path).and_return(nginx_certs_path)
      allow(Dir).to receive(:[]).with("#{tailscale_certs_path}/*.crt").and_return([crt_file])
      allow(Dir).to receive(:[]).with("#{tailscale_certs_path}/*.key").and_return([key_file])
      allow(Dir).to receive(:exist?).with(tailscale_certs_path).and_return(true)
      allow(Dir).to receive(:exist?).with(nginx_certs_path).and_return(true)
      allow(FileUtils).to receive(:cp)
    end

    it 'copies .crt and .key files to the nginx certs path' do
      expect(FileUtils).to receive(:cp).with(crt_file, target_crt_file, verbose: false, noop: false)
      expect(FileUtils).to receive(:cp).with(key_file, target_key_file, verbose: false, noop: false)
      command.setup_nginx_certs
    end
  end

  describe '#setup_yarn', skip: 'TODO: review Gemini 2.5 pro generated setup and examples' do
    let(:tarball_path) { "#{Rails.root}/tmp/yarn-4.9.1.tar.gz" }
    let(:extracted_dir) { "#{Rails.root}/yarn-4.9.1" }
    let(:yarn_path) { "#{Rails.root}/.yarn/releases/yarn-4.9.1.cjs" }
    let(:source_package_path) { "#{extracted_dir}/packages/berry-cli/bin/berry.js" }

    before do
      allow(command).to receive(:system)
      allow(command).to receive(:run)
      allow(command).to receive(:say)
      allow(command).to receive(:say_info)
      allow(command).to receive(:tarball_path).and_return(tarball_path)
      allow(command).to receive(:extracted_dir).and_return(extracted_dir)
      allow(command).to receive(:yarn_path).and_return(yarn_path)
      allow(File).to receive(:read).and_call_original
      allow(ERB).to receive(:new).and_return(double(result: ''))
      allow(File).to receive(:write)
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:cp)
      allow(FileUtils).to receive(:rm_rf)
    end

    context 'when tarball does not exist' do
      before do
        allow(File).to receive(:exist?).with(tarball_path).and_return(false)
        allow(File).to receive(:exist?).with(source_package_path).and_return(true)
      end

      it 'downloads, extracts, and sets up yarn' do
        expect(command).to receive(:run).with(command.send(:yarn_download_cmd))
        command.setup_yarn
        expect(FileUtils).to have_received(:cp).with(source_package_path, yarn_path, verbose: false)
      end
    end

    context 'when tarball already exists' do
      before do
        allow(File).to receive(:exist?).with(tarball_path).and_return(true)
        allow(File).to receive(:exist?).with(source_package_path).and_return(true)
      end

      it 'skips download and sets up yarn' do
        expect(command).not_to receive(:run).with(command.send(:yarn_download_cmd))
        command.setup_yarn
        expect(FileUtils).to have_received(:cp).with(source_package_path, yarn_path, verbose: false)
      end
    end
  end
end

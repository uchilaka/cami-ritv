# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity
  module CLI
    class UtilsCmd < BaseCmd
      namespace :utils

      desc 'sync_certs', 'Sync SSL certificates to Nginx certs directory'
      def setup_certs
        %w[*.crt *.key].each do |pattern|
          Dir["#{tailscale_certs_path}/#{pattern}"].each do |file|
            say_info "Copying #{file} to #{nginx_certs_path}/#{File.basename(file)}"
            FileUtils.cp file, "#{nginx_certs_path}/#{File.basename(file)}", verbose: verbose?, noop: dry_run?
          end
        end
      end

      desc 'kick_nginx_config', 'Kick Nginx to reload its configuration'
      def kick_nginx_config
        if Rails.env.test?
          say 'Skipping Nginx config kick in test environment.', :red
          return
        end

        raise Thor::Error, "Nginx config file not found at #{nginx_config_file}" unless File.exist?(nginx_config_file)

        say 'Kicking Nginx to reload its configuration...', :yellow
        FileUtils.mkdir_p(nginx_servers_path, verbose: verbose?, noop: dry_run?)

        # Symlink the config file
        say "Symlinking Nginx config from #{nginx_config_file} to #{nginx_config_symlink}...", :yellow
        FileUtils.ln_sf nginx_config_file, nginx_config_symlink, verbose: verbose?, noop: dry_run?

        # Symlink each file in the SSL artifacts directory to the Nginx certs directory
        Dir["#{nginx_ssl_artifacts_path}/*.pem"].each do |artifact|
          # TODO: Write a test to assert that the correct basename (with .pem extension) is used
          say "Symlinking Nginx SSL artifact from #{artifact} to #{nginx_ssl_artifacts_symlink}/#{File.basename(artifact)}...", :yellow
          FileUtils.ln_sf artifact, "#{nginx_ssl_artifacts_symlink}/#{File.basename(artifact)}", verbose: verbose?, noop: dry_run?
        end

        say 'Nginx configuration reloaded successfully.', :green

        run 'brew', 'services', 'restart', 'nginx'
        run 'brew', 'services', 'info', 'nginx'
      end

      desc 'setup_yarn', 'Setup Yarn package manager'
      def setup_yarn
        system 'corepack enable'
        if File.exist?(tarball_path)
          say "Yarn tarball already exists at #{tarball_path}. Skipping download.", :green
        else
          say "Downloading Yarn tarball from #{yarn_source_url} to #{tarball_path}", :yellow
          run yarn_download_cmd
        end
        raise Thor::Error, 'Yarn download failed' unless dry_run? || File.exist?(tarball_path)

        # Extract the tarball to the working directory
        flags = %w[zx]
        flags << 'v' if verbose?
        run 'tar', "-#{flags.join}", '-f', tarball_path
        # mv_tarball_contents_to_workspace_dir unless dry_run?
        say "Extracted the Yarn tarball to #{extracted_dir}", :green
        run 'tree -L 1', extracted_dir if verbose?
        source_package_path = Rails.root.join(extracted_dir, 'packages/berry-cli/bin/berry.js').to_s
        unless dry_run?
          raise Thor::Error, "Yarn package not found in tarball (checked at #{source_package_path})" \
            unless File.exist?(source_package_path)

          # Ensure the releases directory exists
          FileUtils.mkdir_p(File.dirname(yarn_path))
          # Copy the Yarn package to the releases directory
          FileUtils.cp(source_package_path, yarn_path, verbose: verbose?)
          # Write out an ERB template for the Yarn config file
          yarn_config_template = File.read(Rails.root.join('config/.yarnrc.yml.erb'))
          yarn_config_content = ERB.new(yarn_config_template).result(binding)
          File.write(Rails.root.join('.yarnrc.yml'), yarn_config_content)
          # Cleanup
          FileUtils.rm_rf(extracted_dir, verbose: verbose?)
          FileUtils.rm_rf(tarball_working_dir, verbose: verbose?)
        end
        # run corepack_activation_cmd
        # run 'yarn set version', target_version
        say 'Yarn has been set up successfully.', :green
      end

      private

      def nginx_ssl_artifacts_symlink
        "#{nginx_path}/certs"
      end

      def nginx_ssl_artifacts_path
        "#{nginx_config_path}/ssl"
      end

      def nginx_config_symlink
        "#{nginx_servers_path}/cami.conf"
      end

      def nginx_config_file
        "#{nginx_config_path}/conf.d/servers.conf"
      end

      def nginx_config_path
        "#{Rails.root}/.nginx/#{Rails.env}"
      end

      def nginx_certs_path
        "#{nginx_path}/certs"
      end

      def tailscale_certs_path
        "#{Dir.home}/Library/Containers/io.tailscale.ipn.macos/Data"
      end

      def nginx_servers_path
        "#{nginx_path}/servers"
      end

      def nginx_path
        @nginx_path ||= ENV.fetch('NGINX_PATH', '/opt/homebrew/etc/nginx')
      end

      def mv_tarball_contents_to_workspace_dir
        FileUtils.mv(extracted_dir, tarball_working_dir)
      end

      def extracted_dir
        extracted_dirname = `tar -tzf "#{tarball_path}" | head -1 | cut -f1 -d"/"`.strip
        Rails.root.join(extracted_dirname).to_s
      end

      def extract_tarball_cmd
        [
          'tar -xzf',
          tarball_path,
          '-C',
          tarball_working_dir,
          # '--strip-components=1',
        ].join(' ')
      end

      def yarn_download_cmd
        [
          'curl -L -o',
          tarball_path,
          yarn_source_url,
        ].join(' ')
      end

      def corepack_activation_cmd
        "corepack prepare yarn@#{target_version} --activate"
      end

      def yarn_source_url
        "https://github.com/yarnpkg/berry/archive/refs/tags/#{target_tag}.tar.gz"
      end

      def target_tag
        "@yarnpkg/cli/#{target_version}"
      end

      def target_version
        '4.9.1'
      end

      def tarball_path
        "#{Rails.root}/tmp/yarn-#{target_version}.tar.gz"
      end

      def tarball_working_dir
        [File.dirname(tarball_path), File.basename(tarball_path, '.tar.gz')].join('/')
      end

      def yarn_path
        "#{Rails.root}/.yarn/releases/yarn-#{target_version}.cjs"
      end
    end
  end
end

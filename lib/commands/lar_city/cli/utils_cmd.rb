# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity
  module CLI
    class UtilsCmd < BaseCmd
      namespace :utils

      no_commands do
        include IoHelpers
      end

      IoHelpers.define_auth_config_path_option(self)
      desc 'httpd', 'Run an httpd Docker container with auth volume mounted'
      def httpd
        cmd = [
          'docker run',
          '--rm',
          "--mount type=volume,source=#{auth_dir_mount_source},target=/auth",
          'httpd:2.4',
          'touch /auth/htpasswd',
        ]
        run(*cmd, inline: true)
      end

      desc 'setup_nginx_certs', 'Sync SSL certificates to Nginx certs directory'
      def setup_nginx_certs
        unless Dir.exist?(tailscale_certs_path)
          missing_dir_msg = <<~MSG
            Tailscale certificates directory not found at #{tailscale_certs_path}. \
            Please ensure Tailscale is installed and configured properly.
          MSG
          raise Thor::Error, missing_dir_msg
        end

        unless Dir.exist?(nginx_certs_path)
          missing_dir_msg = <<~MSG
            NGINX certificates directory not found at #{nginx_certs_path}. \
            Please ensure NGINX is installed and the path is correct.
          MSG
          raise Thor::Error, missing_dir_msg
        end

        copy_over_msg = <<~MSG
          **********************************************************************
          *  Copying SSL certificates from Tailscale to NGINX certs directory  *
          **********************************************************************
        MSG
        say_info copy_over_msg
        dir_info_msg = <<~MSG
          NGINX Certificates Directory: #{nginx_certs_path}
          NGINX Certificates Directory Exists: #{Dir.exist?(nginx_certs_path)}
          Tailscale Certificates Directory: #{tailscale_certs_path}
          Tailscale Certificates Directory Exists: #{Dir.exist?(tailscale_certs_path)}
        MSG
        say_info dir_info_msg if verbose?
        %w[*.crt *.key].each do |pattern|
          resource_pattern = "#{tailscale_certs_path}/#{pattern}"
          say_info "Processing resource pattern: #{resource_pattern}" if verbose?
          Dir[resource_pattern].each do |source_file|
            target_file = "#{nginx_certs_path}/#{File.basename(source_file)}"
            if verbose?
              if dry_run?
                say_highlight "(Dry-run) Copying #{source_file} to #{target_file}"
              else
                say_info "Copying #{source_file} to #{target_file}"
              end
            end
            FileUtils.cp(source_file, target_file, verbose: verbose?, noop: dry_run?)
          end
        end
      end

      desc 'kick_nginx_config', 'Kick Nginx to reload its configuration'
      def kick_nginx_config
        # if Rails.env.test?
        #   say 'Skipping Nginx config kick in test environment.', :red
        #   return
        # end

        raise Thor::Error, "Nginx config file not found at #{nginx_config_file}" unless File.exist?(nginx_config_file)

        say_info 'Kicking Nginx to reload its configuration...'
        FileUtils.mkdir_p(nginx_servers_path, verbose: verbose?, noop: dry_run? || Rails.env.test?)

        # Symlink the config file
        say_info "Symlinking Nginx config from #{nginx_config_file} to #{nginx_config_symlink}..."
        FileUtils.ln_sf(nginx_config_file, nginx_config_symlink, verbose: verbose?, noop: dry_run? || Rails.env.test?)

        # Symlink each file in the SSL artifacts directory to the Nginx certs directory
        Dir["#{nginx_ssl_artifacts_path}/*.pem"].each do |artifact_source|
          link_target = "#{nginx_ssl_artifacts_symlink}/#{File.basename(artifact_source)}"
          say_info "Symlinking Nginx SSL artifact from #{artifact_source} to #{link_target}..."
          FileUtils.ln_sf(artifact_source, link_target, verbose: verbose?, noop: dry_run? || Rails.env.test?)
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

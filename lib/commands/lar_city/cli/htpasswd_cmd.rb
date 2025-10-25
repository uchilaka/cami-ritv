# frozen_string_literal: true

require_relative 'base_cmd'
require 'commands/lar_city/cli/utils/ask'

module LarCity
  module CLI
    class HtpasswdCmd < BaseCmd
      namespace :htpasswd

      def self.define_codegen_options
        option :auth_dir_source,
               type: :string,
               aliases: '-d',
               desc: 'The directory to store the htpasswd file',
               default: 'config/httpd'
      end

      define_codegen_options
      desc 'codegen', 'Manage basic auth records in a htpasswd file'
      long_desc <<-LONGDESC
        This command allows you to manage basic authentication records in a htpasswd file.
        You can add, update, delete, or list users in the specified htpasswd file.
      LONGDESC
      def codegen
        username, password =
          Utils::Ask
            .prompt_for_auth_credentials(creating: true)
            .values_at(:username, :password)

        # Verify the auth directory exists or create it
        auth_dir = options[:auth_dir_source]
        auth_dir = Rails.root.join(auth_dir).to_s unless auth_dir.start_with?('/')
        rel_path = auth_dir.split('/').reject(&:blank?)
        rel_path << 'auth' unless rel_path.last == 'auth'
        auth_dir = Rails.root.join(*rel_path).to_s
        unless Dir.exist?(auth_dir)
          if dry_run?
            say_highlight "Dry-run: Would have created directory #{auth_dir}"
          else
            say_info "Creating directory #{auth_dir}"
            FileUtils.mkdir_p(auth_dir)
          end
        end

        cmd = [
          'docker run',
          '--rm',
          '--entrypoint htpasswd',
          "--mount type=volume,source=#{auth_dir},target=/auth",
          'httpd:2', '-Bbn', username, password,
          (windows? ? '| Set-Content -Encoding ASCII auth/htpasswd' : '> auth/htpasswd'),
        ]
        run(*cmd, inline: true)
      end
    end
  end
end

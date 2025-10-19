# frozen_string_literal: true

require 'lar_city/cli/utils'
require 'lib/commands/lar_city/cli/htpasswd_cmd'

class HtpasswdGenerator < Rails::Generators::Base
  # include LarCity::CLI::OutputHelpers

  attr_accessor :username, :password, :auth_dir_mount_source

  source_root File.expand_path('templates', File.dirname(__FILE__))

  # This sets the description shown when running `bin/rails generate --help`
  desc 'This generator creates a placeholder .htpasswd file for basic HTTP authentication.'

  LarCity::CLI::BaseCmd.define_class_options

  class_option :auth_config_path,
               type: :string,
               aliases: '-o',
               desc: 'The directory to store the htpasswd file',
               default: 'config/httpd'

  # --- Sequential steps ---

  def prompt_for_credentials
    @username, @password =
      LarCity::CLI::Utils::Ask
        .prompt_for_auth_credentials(creating: true)
        .values_at(:username, :password)
  end

  def show_credentials
    say_highlight "Username: #{@username}"
    say_highlight "Password: #{@password}"
  end

  def setup_auth_config_directory
    @auth_dir_mount_source ||=
      begin
        auth_dir =
          if auth_config_path.start_with?('/')
            auth_config_path
          else
            Rails.root.join(auth_config_path).to_s
          end

        rel_path = auth_dir.split('/').reject(&:blank?)
        rel_path << 'auth' unless rel_path.last == 'auth'
        auth_dir = Rails.root.join(*rel_path).to_s

        if Dir.exist?(auth_dir)
          say_status :exist, "directory: #{auth_dir}" if verbose?
        elsif dry_run?
          say_highlight "Dry-run: Would have created directory #{auth_dir}"
        else
          say_status :create, "directory: #{auth_dir}" if verbose?
          FileUtils.mkdir_p(auth_dir)
        end

        auth_dir
      end
  end

  no_commands do
    include ::LarCity::CLI::OutputHelpers
    include ::LarCity::CLI::Runnable

    def auth_config_path
      options[:auth_config_path]
    end
  end
end

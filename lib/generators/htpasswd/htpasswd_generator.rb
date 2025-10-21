# frozen_string_literal: true

require 'lar_city/cli/utils'
require 'lib/commands/lar_city/cli/htpasswd_cmd'

class HtpasswdGenerator < Rails::Generators::Base
  attr_accessor :username, :password

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
    credentials = { username:, password: partially_masked_secret(password) }
    say_highlight "Generated HTTP basic auth credentials: #{credentials}"
  end

  def setup_auth_config_directory
    auth_dir_mount_source
  end

  def codegen
    output_redirection_fragment =
      (windows? ? '| Set-Content -Encoding ASCII /auth/htpasswd' : '> /auth/htpasswd')
    cmd = [
      'docker run',
      '--rm',
      '--entrypoint htpasswd',
      "--mount type=volume,source=#{auth_dir_mount_source},target=/auth",
      'httpd:2', '-Bbn', username, password,
      output_redirection_fragment,
    ]
    run(*cmd, inline: true)
  end

  no_commands do
    include ::LarCity::CLI::EnvHelpers
    include ::LarCity::CLI::IoHelpers
    include ::LarCity::CLI::OutputHelpers
    include ::LarCity::CLI::Runnable
  end
end

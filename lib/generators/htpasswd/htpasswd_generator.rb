# frozen_string_literal: true

require 'lar_city/cli/utils'
# require 'lib/commands/lar_city/cli/htpasswd_cmd'

class HtpasswdGenerator < Rails::Generators::Base
  no_commands do
    include ::LarCity::CLI::EnvHelpers
    include ::LarCity::CLI::IoHelpers
    include ::LarCity::CLI::OutputHelpers
    include ::LarCity::CLI::Runnable
  end

  attr_accessor :username, :password

  source_root File.expand_path('templates', File.dirname(__FILE__))

  # This sets the description shown when running `bin/rails generate --help`
  desc 'This generator creates a placeholder .htpasswd file for basic HTTP authentication.'

  # LarCity::CLI::BaseCmd.define_class_options
  ::LarCity::CLI::EnvHelpers.define_class_options(self)
  ::LarCity::CLI::OutputHelpers.define_class_options(self)
  ::LarCity::CLI::IoHelpers.define_auth_config_path_option(self, class_option: true)

  # --- Sequential steps ---

  def prompt_for_credentials
    return if help?

    @username, @password =
      ::LarCity::CLI::Utils::Ask
        .prompt_for_auth_credentials(creating: true)
        .values_at(:username, :password)
  end

  def show_credentials
    return if help?

    credentials = { username:, password: partially_masked_secret(password) }
    say_highlight "Generated HTTP basic auth credentials: #{credentials}"
  end

  def setup_auth_config_directory
    auth_dir_mount_source
  end

  # IMPORTANT: ⚠️ This step currently ONLY supports creating new htpasswd files
  # and will overwrite any existing file without warning. To refactor for better
  # management (add/update/delete/list users), consider implementing a more
  # interactive CLI command or using a dedicated library for htpasswd management
  # or review the --help output of this group command.
  def codegen
    if help?
      run(*run_cmd_prefix, '--help', inline: true)
    else
      codegen_target_file = File.join(auth_dir_mount_source, 'htpasswd')
      output_redirection_fragment =
        (windows? ? "| Set-Content -Encoding ASCII #{codegen_target_file}" : "> #{codegen_target_file}")
      run(*run_cmd_prefix, '-Bbn', username, password, output_redirection_fragment, inline: true)
      say_success "Created .htpasswd file at #{codegen_target_file}" unless pretend?
    end
  end

  no_commands do
    def run_cmd_prefix
      %w[docker run --rm --entrypoint htpasswd httpd:2]
    end
  end
end

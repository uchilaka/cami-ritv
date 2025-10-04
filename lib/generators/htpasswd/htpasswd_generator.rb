# frozen_string_literal: true

require 'lib/commands/lar_city/cli/devkit_cmd'

class HtpasswdGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', File.dirname(__FILE__))

  # This sets the description shown when running `bin/rails generate --help`
  desc 'This generator creates a placeholder .htpasswd file for basic HTTP authentication.'

  LarCity::CLI::BaseCmd.define_class_options

  class_option :file, type: :string, default: '.htpasswd', desc: 'The name of the .htpasswd file to create'

  def generate_htpasswd_file
    # Access the filename from the options hash
    file_path = options['file']
    auth_dir_source =
      if file_path.start_with?('/')
        File.dirname(file_path)
      else
        rel_path = ['config', File.dirname(file_path)].uniq
        Rails.root.join(*rel_path)
      end
    command = LarCity::CLI::DevkitCmd.new
    command
      .invoke(
        :htpasswd_codegen, [],
        dry_run: options[:dry_run],
        verbose: options[:verbose],
        auth_dir_source:,
      )
  end
end

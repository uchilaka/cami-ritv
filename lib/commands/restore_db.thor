# frozen_string_literal: true

require 'lar_city/base_cmd_stack'
require 'lar_city/cli/utils'

class RestoreDb < Thor::Group
  include LarCity::BaseCmdStack

  class_option :target,
               type: :string,
               required: true,
               desc: 'Target database to restore (e.g., crm)',
               enum: %w[primary crm],
               default: 'primary'

  desc 'Command to restore a database from a backup file'

  def check_for_available_backups
    list_available_backups
  end

  def prompt_for_backup_file
    file_pos = prompt_for_data_source_file
    prioritized_recent_files = available_backup_files.last(3).reverse
    data_source_file = prioritized_recent_files[file_pos.to_i - 1]
    say_info "Selected backup file: #{data_source_file}"
  end

  no_commands do
    def prompt_for_data_source_file(cli: HighLine.new)
      data_source_prompt = <<~PROMPT
      Enter a selection for the data source backup file to restore
      for target '#{options[:target]}':
    PROMPT
      cli.ask data_source_prompt do |q|
        q.validate = /\A\w+\Z/
      end
    end

    def list_available_backups
      files = available_backup_files
      if files.empty?
        say_warning 'No backup files found.'
      else
        say_info "Last 3 available backup files for target (latest first) '#{options[:target]}':"
        files.last(3).reverse.each_with_index do |file, pos|
          natural_pos = pos + 1
          say " #{natural_pos}. #{file}"
        end
      end
    end

    def available_backup_files
      Dir.glob(File.join(backup_dir, "#{options[:target]}*.dump")).map { |f| File.basename(f) }
    end

    def backup_dir
      Rails.root.join('db', Rails.env, 'postgres', 'backups')
    end
  end
end

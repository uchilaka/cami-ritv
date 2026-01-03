# frozen_string_literal: true

require 'lar_city/base_cmd_stack'
require 'lar_city/cli/utils'

class RestoreDb < Thor::Group
  include LarCity::BaseCmdStack

  attr_reader :data_source_file, :restore_file

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

  def select_backup_file_from_prioritized_list
    @data_source_file = selected_data_source_file
    while data_source_file.nil?
      say_warning 'Invalid selection. Please try again.'
      @data_source_file = selected_data_source_file
    end
    say_info "Selected backup file: #{data_source_file}"
  end

  def copy_backup_file_to_mounted_volume
    source_path = File.join(backup_path, data_source_file)
    say_highlight "Source backup file path: #{source_path}" if verbose?
    @restore_file = "#{options[:target]}_restore.dump"
    dest_path = File.join(downloads_path, restore_file)
    say_highlight "Destination mounted path: #{dest_path}" if verbose?
    say_info "Copying backup file from '#{source_path}' to '#{dest_path}'"
    FileUtils.cp(source_path, dest_path, verbose: verbose?, noop: pretend?)
  end

  def restore_database_from_backup
    database_config = Rails.application.config_for(:database)[:primary]
    username, port, host, password, database =
      database_config.values_at(:username, :port, :host, :password, :database)
    cmd_parts = %w[pg_restore --jobs 8 --verbose --clean]
    cmd_parts << "--verbose" if verbose?
    cmd_parts += %W[--username='#{username}' --host='#{host}' --port='#{port}' --dbname='#{restore_database}']
    cmd_parts << (password.blank? ? '--no-password' : '--password')
    cmd_parts << restore_source_path
    run *cmd_parts
  end

  no_commands do
    def restore_database
      case options[:target]
      when 'crm'
        "twenty_crm_#{Rails.env}"
      else
        "sails_#{Rails.env}"
      end
    end

    def restore_source_path(context: nil)
      base_path = context.to_s == 'container' ? '/usr/local/downloads' : downloads_path
      File.join(base_path, restore_file)
    end

    def selected_data_source_file
      file_pos = prompt_for_data_source_file
      prioritized_recent_files = available_backup_files.last(3).reverse
      if prioritized_recent_files.empty?
        resource = 'Database backup files'
        raise StandardError, I18n.t('exceptions.not_found_short', resource:)
      end

      prioritized_recent_files[file_pos.to_i - 1]
    end

    def prompt_for_data_source_file(cli: HighLine.new)
      additional_info = " for target '#{options[:target]}'"
      data_source_prompt =
        I18n.t('prompts.select_db_backup_source_file', additional_info:)
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
          say " (#{natural_pos}) #{file}"
        end
      end
    end

    def available_backup_files
      Dir.glob(File.join(backup_path, "#{options[:target]}*.dump")).map { |f| File.basename(f) }
    end

    def app_store_volume_path
      Rails.root.join('db', Rails.env, 'postgres')
    end

    def backup_path
      File.join(app_store_volume_path, 'backups')
    end

    def downloads_path
      File.join(app_store_volume_path, 'downloads')
    end
  end
end

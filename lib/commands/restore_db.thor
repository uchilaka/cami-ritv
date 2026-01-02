# frozen_string_literal: true

require 'lar_city/base_cmd_stack'

class RestoreDb < Thor::Group
  include LarCity::BaseCmdStack

  class_option :target,
               type: :string,
               required: true,
               desc: 'Target database to restore (e.g., crm)',
               enum: %w[primary crm],
               default: 'primary'

  desc 'Command to restore a database from a backup file'

  def list_available_backups
    files = available_backup_files
    if files.empty?
      say_warning 'No backup files found.'
    else
      say_info "Last 3 available backup files for target (latest first) '#{options[:target]}':"
      files.last(3).reverse.each do |file|
        say " - #{file}"
      end
    end
  end

  no_commands do
    def available_backup_files
      Dir.glob(File.join(backup_dir, "#{options[:target]}*.dump")).map { |f| File.basename(f) }
    end

    def backup_dir
      Rails.root.join('db', Rails.env, 'postgres', 'backups')
    end
  end
end

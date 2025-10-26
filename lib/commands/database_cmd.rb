# frozen_string_literal: true

require_relative 'lar_city/cli/base_cmd'

class DatabaseCmd < LarCity::CLI::BaseCmd
  namespace :db

  def self.available_config_keys
    Rails.configuration.database_configuration['production'].keys
  end

  class_option :name,
               desc: 'The configuration (key) name of the database to operate on',
               type: :string,
               enum: available_config_keys,
               aliases: '-n',
               default: 'primary',
               required: true

  desc 'backup', 'Backup the database contents to a file'
  def backup
    with_optional_pretend_safety do
      if help?
        run 'pg_dump', '--help', inline: true
        return
      end

      abs_backup_path = "#{Rails.root}/#{backup_path}"
      FileUtils.mkdir_p(abs_backup_path, verbose: verbose?, noop: pretend?)
      dump_file = "#{abs_backup_path}/#{options[:name]}_#{file_timestamp}.dump"
      say_info "Backing up database to #{dump_file}..."
      run 'pg_dump', *pg_dump_options,
          "--username=#{config['username']}",
          "--host=#{config['host']}",
          "--port=#{config['port']}",
          "--file=\"#{dump_file}\"",
          config['database']
      say_success "Database backup completed: #{dump_file}" unless pretend?
    end
  end

  private

  def pg_dump_options
    @pg_dump_options =
      %w[
        --format=custom
        --no-owner
        --no-privileges
        --encoding=UTF-8
      ]
    @pg_dump_options << '--no-password' if config['password'].blank?
    @pg_dump_options << '--verbose' if verbose?
  end

  def file_timestamp
    Time.now.strftime('%Y%m%d.%H%M%S.%z')
  end

  def config
    @config ||= Rails.configuration.database_configuration.dig(detected_environment.to_s, options[:name])
  end

  def backup_path
    @backup_path ||= "db/#{detected_environment}/postgres/backups"
  end

  def schema_name
    @schema_name ||= config['database']
  end
end

# frozen_string_literal: true

require 'lar_city/base_cmd_stack'
require 'lar_city/cli/services_cmd'
require_relative 'features_cmd'
require_relative 'kick_store_cmd'

class InitApp < Thor::Group
  include LarCity::BaseCmdStack

  desc 'Command to initialize the application'

  class_option :restore_primary, type: :boolean, default: false, desc: 'Restore primary database from latest backup'
  class_option :restore_crm, type: :boolean, default: false, desc: 'Restore CRM database from latest backup'

  def setup_paths
    if Dir.exist?(app_store_resource_path)
      say_info "Application resource path already exists at: #{app_store_resource_path}"
    else
      say_info "Setting up application resource path at: #{app_store_resource_path}"
      FileUtils.mkdir_p(app_store_resource_path, verbose: verbose?, noop: pretend?)
    end
  end

  def touch_keep_file_for_app_store_downloads
    say_info "Creating .keep file in application resource path at: #{app_store_resource_path}"
    FileUtils.touch(File.join(app_store_resource_path, '.keep'), verbose: verbose?, noop: pretend?)
  end

  def start_database_service
    run 'docker-compose up', '--detach app-store'
  end

  def kick_stores
    # @FIXME The primary database should be last until we can explicitly target it
    #   for subsequent commands
    %w[crm primary].each do |target|
      restore = target.to_s == 'crm' ? options[:restore_crm] : options[:restore_primary]
      kick_cmd =
        KickStoreCmd
          .new(
            [], target:, restore:,
            verbose: verbose?,
            dry_run: pretend?,
          )
      kick_cmd.invoke_all
    end
  end

  def apply_data_migrations
    Rails::Command.invoke('data:migrate')
  end

  def setup_feature_flags
    svc = FeaturesCmd.new
    svc.invoke(:init, [], dry_run: pretend?, verbose: verbose?)
  end

  def maybe_restore_crm_database_from_backup
    return unless options[:restore_crm]

    say_info 'Restoring CRM database from latest backup...'
    restore_database_from_backup(target: 'crm')
  end

  def start_all_services
    svc = LarCity::CLI::ServicesCmd.new
    svc.invoke(:start, [], dry_run: pretend?, verbose: verbose?)
  end

  no_commands do

    # @TODO Explore refactoring to use `rails db:seed:primary` and `rails db:seed:crm` instead
    def restore_database_from_backup(target: 'primary')
      restore_cmd = RestoreDb.new([], target:, latest_backup: true, verbose: verbose?, dry_run: pretend?)
      restore_cmd.invoke_all
    end

    def app_store_resource_path
      Rails.root.join('db', Rails.env, 'postgres', 'downloads')
    end
  end
end

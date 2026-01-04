# frozen_string_literal: true

require 'lar_city/base_cmd_stack'
require 'lar_city/cli/services_cmd'
require_relative 'restore_db'

class InitApp < Thor::Group
  include LarCity::BaseCmdStack

  desc 'Command to initialize the application'

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

  def wait_for_database_service_health_check
    wait_for_db
  end

  def create_data_stores_if_not_exists
    Rails::Command.invoke("db:create:primary")
    Rails::Command.invoke("db:create:crm")
  end

  def apply_migrations
    Rails::Command.invoke("db:migrate:primary")
    Rails::Command.invoke("db:migrate:crm")
  end

  def restore_crm_database_from_backup
    restore_cmd = RestoreDb.new([], target: 'crm', latest_backup: true, verbose: verbose?, dry_run: pretend?)
    restore_cmd.invoke_all
  end

  def start_all_services
    svc = LarCity::CLI::ServicesCmd.new
    svc.invoke(:start, [], dry_run: pretend?, verbose: verbose?)
  end

  no_commands do
    def app_store_resource_path
      Rails.root.join('db', Rails.env, 'postgres', 'downloads')
    end
  end
end

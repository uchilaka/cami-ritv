# frozen_string_literal: true

require 'lar_city/base_cmd_stack'
require_relative 'restore_db'

class KickStoreCmd < Thor::Group
  include LarCity::BaseCmdStack

  no_commands do
    def self.database_config
      @database_config ||= Rails.application.config_for(:database)
    end

    def self.available_stores
      database_config.keys.map(&:to_s)
    end
  end

  delegate :database_config, to: :class

  namespace :'kick-store'

  class_option :target,
               desc: 'The data store by name to kick',
               type: :string,
               aliases: '-t',
               enum: available_stores,
               default: 'primary'
  class_option :restore,
               type: :boolean,
               default: false,
               desc: 'Restore database from latest backup'

  def create_data_store_if_not_exists
    if skip_database_tasks?
      say_debug "Skipping #{target} store create"
      return
    end

    say_info "Creating #{target} data store (unless EXISTS)..."
    Rails::Command.invoke("db:create:#{target}")
  end

  def wait_for_database_service_health_check
    wait_for_db(target:)
  end

  def maybe_restore_database_from_backup
    if skip_database_tasks?
      say_debug "Skipping #{target} data restore"
      return
    end
    return unless options[:restore]

    say_info "Restoring #{target} database from latest backup..."
    restore_database_from_backup(target: target.to_s)
  end

  def apply_migrations
    return if skip_database_tasks?

    Rails::Command.invoke("db:migrate:#{target}")
  end

  private

  # @TODO Explore refactoring to use `rails db:seed:primary` and `rails db:seed:crm` instead
  def restore_database_from_backup(target:)
    restore_cmd = RestoreDb.new([], target:, latest_backup: true, verbose: verbose?, dry_run: pretend?)
    restore_cmd.invoke_all
  end

  def app_store_resource_path
    Rails.root.join('db', Rails.env, 'postgres', 'downloads')
  end

  def skip_database_tasks?
    run_tasks = database_config.dig(target, :database_tasks)
    return false if run_tasks.nil?

    run_tasks == false
  end

  def target
    options[:target].to_sym
  end
end

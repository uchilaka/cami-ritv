# frozen_string_literal: true

require 'lar_city/base_cmd_stack'
require 'lar_city/cli/services_cmd'

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
    run 'docker-compose up',
        '--detach app-store'
  end

  def wait_for_database_service_health_check
    # Perform a health check to ensure the database service
    # is ready to accept connections.
    wait_for_db
  end

  # Create the CRM database
  def create_crm_database
    host, port, user =
      database_config[:app].values_at(:host, :port, :user)
    db_name = database_config.dig(:crm, :name)

    run 'createdb',
        "--host #{host}",
        "--port #{port}",
        "--username #{user}",
        db_name
  end

  def start_all_services
    svc = LarCity::CLI::ServicesCmd.new
    svc.invoke(:start, [], pretend: pretend?, verbose: verbose?)
  end

  no_commands do
    def app_store_resource_path
      Rails.root.join('db', Rails.env, 'postgres', 'downloads')
    end

    def database_config
      {
        app: {
          host: ENV.fetch('APP_DATABASE_HOST'),
          port: ENV.fetch('APP_DATABASE_PORT'),
          user: ENV.fetch('APP_DATABASE_USER'),
          name: ENV.fetch('APP_DATABASE_NAME'),
        },
        crm: crm_database_config,
      }
    end

    def crm_database_config
      {
        host: ENV.fetch('PG_DATABASE_HOST', 'crm-store'),
        port: ENV.fetch('PG_DATABASE_PORT', '5432'),
        user: ENV.fetch('APP_DATABASE_USER', 'postgres'),
        name: ENV.fetch('CRM_DATABASE_NAME', 'lar_city_crm_db'),
      }
    end
  end
end

# frozen_string_literal: true

require 'lar_city/base_cmd_stack'

class InitApp < Thor::Group
  include LarCity::BaseCmdStack

  desc 'Command to initialize the application'

  def self.exit_on_failure?
    true
  end

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

  no_commands do
    def app_store_resource_path
      Rails.root.join('db', Rails.env, 'postgres', 'downloads')
    end
  end
end

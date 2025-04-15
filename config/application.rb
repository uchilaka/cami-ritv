# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
# require "active_job/railtie"
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"
require 'active_support/core_ext/integer/time'

# See https://stackoverflow.com/a/837593/3726759
$LOAD_PATH.unshift(Dir.pwd)

require 'lib/app_utils'
require 'lib/virtual_office_manager'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cami
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.application_name = 'Customer Account Management & Invoicing'
    config.application_short_name = 'CAMI'


    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    # Read more on ignoring resources:
    # https://guides.rubyonrails.org/classic_to_zeitwerk_howto.html#having-app-in-the-autoload-paths
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_support.to_time_preserves_timezone = :zone

    config.active_record.query_log_tags =
      %i[
        application
        controller
        namespaced_controller
        action
        db_host
        database
        job
      ]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << "#{root}/lib"
    config.eager_load_paths << "#{root}/app/concerns"

    # Autoload paths
    config.autoload_paths << "#{root}/lib/workflows"
    config.autoload_paths << "#{root}/lib/commands"
    config.autoload_paths << "#{root}/config/vcr"

    # TODO: Make sure all the directories in the autoload_paths are present in the eager_load_paths
    diff = config.eager_load_paths - config.autoload_paths
    diff.each { |path| config.eager_load_paths << path }

    config.assets.paths << "#{root}/vendor/assets"
  end
end

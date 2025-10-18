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

require 'lib/lar_city'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cami
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.application_name = I18n.t('globals.app.name')
    config.application_short_name = I18n.t('globals.app.short_name')

    # Show full error reports?
    config.consider_all_requests_local = AppUtils.debug_mode?

    config.exceptions_app = lambda { |env|
      ErrorsController.action(:show).call(env)
    }

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
    config.eager_load_paths << "#{root}/lib/generators"
    config.eager_load_paths << "#{root}/app/concerns"
    config.eager_load_paths << "#{root}/app/queries"
    Dir["#{root}/lib/generators/*"].each do |path|
      next unless File.directory?(path)

      config.eager_load_paths << path
    end

    # Autoload paths
    config.autoload_paths << "#{root}/lib/workflows"
    config.autoload_paths << "#{root}/lib/commands"
    config.autoload_paths << "#{root}/config/vcr"

    # TODO: Make sure all the directories in the autoload_paths are present in the eager_load_paths
    diff = config.eager_load_paths - config.autoload_paths
    diff.each { |path| config.eager_load_paths << path }

    # Configure allowed hosts. See doc https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
    config.hosts += config_for(:allowed_hosts)

    # Configure allowed hosts. See doc https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
    config.hosts += config_for(:allowed_hosts)

    # Doc for jbuilder: https://github.com/rails/jbuilder
    Jbuilder.key_format lambda { |key|
      # Customize key formatting for JBuilder to support a configurable set
      # of keys that should NOT be camelized.
      AppUtils.jbuilder_pre_keys.include?(key.to_sym) ? key : key.camelize(:lower)
    }
    Jbuilder.deep_format_keys true

    # # Configure CSS compressor
    # config.assets.css_compressor = :sass

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end

# frozen_string_literal: true

if defined?(RailsLiveReload)
  RailsLiveReload.configure do |config|
    # config.url = "/rails/live/reload"

    # Default watched folders & files
    config.watch %r{app/views/.+\.(erb|haml|slim)$}
    # Test: https://regex101.com/r/eKeGef/1
    config.watch %r{(app|vendor)/(assets|javascript|frontend)/\w+/(.+\.((s?css)|html|png|jpg|(tsx?)|(jsx?))).*},
                 reload: :always

    # More examples:
    # config.watch %r{app/helpers/.+\.rb}, reload: :always
    # config.watch %r{config/locales/.+\.yml}, reload: :always

    # TODO: Re-visit if/when this PR is merged: https://github.com/railsjazz/rails_live_reload/pull/42
    config.enabled = AppUtils.live_reload_enabled?
  end
end

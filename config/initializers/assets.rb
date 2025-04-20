# Be sure to restart your server when you modify this file.

Rails.application.configure do
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Add additional assets to the asset load path.
  # config.assets.paths << Emoji.images_path
  config.assets.paths << "#{root}/vendor/assets"
  # config.assets.paths << "#{root}/node_modules/tailwindcss"
  # config.assets.paths << "#{root}/node_modules/flowbite"
  # config.assets.paths << "#{root}/node_modules/@fortawesome"

  # # Exclude assets that will be pre-compiled
  # config.assets.excluded_paths << "#{root}/app/assets/stylesheets"
end

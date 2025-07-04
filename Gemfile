source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0'
gem 'solid_queue'

gem 'mission_control-jobs'

# Autoload dotenv in Rails https://github.com/bkeepers/dotenv
# IMPORTANT: This should be loaded as early as possible
gem 'dotenv', groups: %i[development test], require: 'dotenv/load'

# Feature rich logging framework that replaces the Rails logger.
gem 'rails_semantic_logger'

# Better Stack Rails integration
gem 'logtail-rails'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'dartsass-rails', '~> 0.5'
gem 'sassc-rails', '~> 2.1'

gem 'cssbundling-rails'
gem 'inertia_rails'
gem 'turbo-rails'
# Setup guide https://v3.tailwindcss.com/docs/installation/using-postcss
gem 'tailwindcss-rails', '~> 3.3'
gem 'tailwindcss-ruby', '~> 3.4'
gem 'vite_rails'

# Use Active Storage variants https://guides.rubyonrails.org/active_storage_overview.html#transforming-images
gem 'image_processing', '~> 1.2'

# A fast image processing library with low memory needs
gem 'ruby-vips', '~> 2.2'

gem 'devise'
gem 'devise-jwt', '~> 0.12'
gem 'devise-passwordless', '~> 1.1'
gem 'omniauth-apple', '~> 1.3'
gem 'omniauth-google-oauth2', '~> 1.2'
gem 'omniauth-rails_csrf_protection'
gem 'rack-cors', '~> 2.0'
gem 'simple_form', '~> 5.3'

# Not supported yet on Rails 8.0
# gem 'active_record_extended'

gem 'aasm'
# Required by AASM
gem 'after_commit_everywhere', '~> 1.6'

gem 'active_model_serializers'
gem 'awesome_print'
gem 'bumbler'
gem 'data_migrate', '~> 11.3'
gem 'discard', '~> 1.4'
gem 'faraday', '~> 2.13'
gem 'faraday-retry'
gem 'friendly_id', '~> 5.5'
gem 'globalid', '~> 1.2'
gem 'interactor', '~> 3.1'
gem 'money-rails', '~> 1.15'
gem 'name_of_person'
gem 'paper_trail', '~> 16'
gem 'phonelib'
gem 'pundit', '~> 2.5'
gem 'ransack', '~> 4.3'
gem 'rolify', '~> 6.0'

# Rationale: setup "staging" environments to be identical to production, distinguished by their domain name.
gem 'sib-api-v3-sdk', groups: %i[production]

gem 'flipper-active_record', '~> 1.3'
gem 'flipper-api'
gem 'flipper-ui'

# OpenAPI (formerly named Swagger) tooling for Rails APIs https://github.com/rswag/rswag
gem 'rswag-api'
gem 'rswag-ui'

# See https://youtrack.jetbrains.com/issue/RUBY-32741/Ruby-Debugger-uninitialized-constant-ClassDebaseValueStringBuilder...#focus=Comments-27-9677540.0-0
gem 'ostruct'

# Simple, feature rich ascii table generation library https://github.com/tj/terminal-table
gem 'terminal-table'

gem 'nokogiri'
gem 'reverse_markdown'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  gem 'brakeman', require: false
  gem 'climate_control'
  gem 'fabrication'
  gem 'faker'
  gem 'open3'
  gem 'rspec-rails', '~> 7'
  gem 'rswag-specs'
  gem 'rubocop', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'strong_migrations'
end

group :development do
  # Ruby on Rails Live Reload https://github.com/railsjazz/rails_live_reload
  gem 'rails_live_reload'

  # Speed up commands on slow machines / big apps https://github.com/rails/spring
  # gem "spring"
  # Use console on exceptions pages https://github.com/rails/web-console
  gem 'web-console'

  # Annotates Rails Models, routes, fixtures, and others based on the database schema.
  gem 'annotaterb'

  # Preview mail in browser instead of sending https://github.com/ryanb/letter_opener
  gem 'letter_opener'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'rails-controller-testing'
  gem 'rubocop-capybara', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'vcr', '~> 6.2'
end

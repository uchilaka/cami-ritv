# frozen_string_literal: true

# Guide: https://guides.rubyonrails.org/i18n.html#configure-the-i18n-module

# Where the I18n library should search for translation files
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

# Permitted locales available for the application. See ISO 639-1 language codes:
# https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes#Table_of_all_possible_two-letter_codes
I18n.available_locales = [:en]

# Set default locale to something other than :en
I18n.default_locale = :en

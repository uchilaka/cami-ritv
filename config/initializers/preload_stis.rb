# frozen_string_literal: true

# Doc on pre-loading collapsed directories: https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#option-2-preload-a-collapsed-directory
sti_model_paths = %w[users].map { |dir| "#{Rails.root}/app/models/#{dir}" }

sti_model_paths.each do |path|
  Rails.autoloaders.main.collapse(path) # Not a namespace
end

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    sti_model_paths.each do |path|
      Rails.autoloaders.main.eager_load_dir(path)
    end
  end
end

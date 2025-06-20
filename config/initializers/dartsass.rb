# frozen_string_literal: true

require 'fileutils'

dartsass_config_map = {
  'application.scss' => 'application.css',
  'actiontext.scss' => 'actiontext.css',
  'errors.scss' => 'errors.css',
}

# WIP: Prepare application stylesheet from template
Dir[Rails.root.join('app', 'assets', 'stylesheets', '*.scss.erb')].each do |sass_template|
  Rails.logger.info('Processing ERB', sass_template:)
  file_name = File.basename(sass_template, File.extname(sass_template))
  output_file = Rails.root.join('app', 'assets', 'stylesheets', file_name.to_s).to_s
  compiled_file_name = "#{File.basename(output_file, File.extname(output_file))}.css"
  sass_content = ERB.new(File.read(sass_template)).result
  File.write output_file, sass_content
  dartsass_config_map[file_name] = compiled_file_name
end

Rails.logger.info('Configuring Dart SASS', dartsass_config_map:)

Rails.application.config.dartsass.builds = dartsass_config_map

# -*- encoding: utf-8 -*-
# stub: rails_live_reload 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_live_reload".freeze
  s.version = "0.4.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Igor Kasyanchuk".freeze, "Liubomyr Manastyretskyi".freeze]
  s.date = "2024-12-19"
  s.description = "Ruby on Rails Live Reload with just a single line of code - just add the gem to Gemfile.".freeze
  s.email = ["igorkasyanchuk@gmail.com".freeze, "manastyretskyi@gmail.com".freeze]
  s.homepage = "https://github.com/railsjazz/rails_live_reload".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.22".freeze
  s.summary = "Ruby on Rails Live Reload".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<railties>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<listen>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<websocket-driver>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<nio4r>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<wrapped_print>.freeze, [">= 0".freeze])
end

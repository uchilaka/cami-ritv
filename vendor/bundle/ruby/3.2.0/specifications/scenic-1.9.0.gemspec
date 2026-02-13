# -*- encoding: utf-8 -*-
# stub: scenic 1.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "scenic".freeze
  s.version = "1.9.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "funding-uri" => "https://github.com/scenic-views/scenic" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Derek Prior".freeze, "Caleb Hearth".freeze]
  s.date = "2025-06-30"
  s.description = "    Adds methods to ActiveRecord::Migration to create and manage database views\n    in Rails\n".freeze
  s.email = ["derekprior@gmail.com".freeze, "caleb@calebhearth.com".freeze]
  s.homepage = "https://github.com/scenic-views/scenic".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.6.2".freeze
  s.summary = "Support for database views in Rails migrations".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, [">= 1.5".freeze])
  s.add_development_dependency(%q<database_cleaner>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.3".freeze])
  s.add_development_dependency(%q<pg>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<ammeter>.freeze, [">= 1.1.3".freeze])
  s.add_development_dependency(%q<yard>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<redcarpet>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<standard>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.0.0".freeze])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 4.0.0".freeze])
end

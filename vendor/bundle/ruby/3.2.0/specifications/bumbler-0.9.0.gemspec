# -*- encoding: utf-8 -*-
# stub: bumbler 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "bumbler".freeze
  s.version = "0.9.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ian MacLeod".freeze]
  s.date = "2022-04-16"
  s.description = "Find slowly loading gems for your Bundler-based projects".freeze
  s.email = ["ian@nevir.net".freeze]
  s.executables = ["bumbler".freeze]
  s.files = ["bin/bumbler".freeze]
  s.homepage = "https://github.com/nevir/Bumbler".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Find slowly loading gems for your Bundler-based projects".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<bump>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<maxitest>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0".freeze])
end

# -*- encoding: utf-8 -*-
# stub: logtail-rack 0.2.6 ruby lib

Gem::Specification.new do |s|
  s.name = "logtail-rack".freeze
  s.version = "0.2.6".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/logtail/logtail-ruby-rack/blob/master/README.md", "homepage_uri" => "https://github.com/logtail/logtail-ruby-rack", "source_code_uri" => "https://github.com/logtail/logtail-ruby-rack" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Better Stack".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-02-11"
  s.email = ["hello@betterstack.com".freeze]
  s.homepage = "https://github.com/logtail/logtail-ruby-rack".freeze
  s.licenses = ["ISC".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Logtail integration for Rack".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<logtail>.freeze, ["~> 0.1".freeze])
  s.add_runtime_dependency(%q<rack>.freeze, [">= 1.2".freeze, "< 4.0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 10.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
end

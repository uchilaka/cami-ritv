# -*- encoding: utf-8 -*-
# stub: logtail-rails 0.2.10 ruby lib

Gem::Specification.new do |s|
  s.name = "logtail-rails".freeze
  s.version = "0.2.10".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/logtail/logtail-ruby-rails/blob/main/README.md", "homepage_uri" => "https://github.com/logtail/logtail-ruby-rails", "source_code_uri" => "https://github.com/logtail/logtail-ruby-rails" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Better Stack".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-02-11"
  s.email = ["hello@betterstack.com".freeze]
  s.homepage = "https://github.com/logtail/logtail-ruby-rails".freeze
  s.licenses = ["ISC".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Better Stack Rails integration".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<logtail>.freeze, ["~> 0.1".freeze, ">= 0.1.14".freeze])
  s.add_runtime_dependency(%q<logtail-rack>.freeze, ["~> 0.1".freeze])
  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 5.0.0".freeze])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0.0".freeze])
  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 5.0.0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0.8".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<bundler-audit>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rails_stdout_logging>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec-its>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 2.3".freeze])
  s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.5.0".freeze])
end

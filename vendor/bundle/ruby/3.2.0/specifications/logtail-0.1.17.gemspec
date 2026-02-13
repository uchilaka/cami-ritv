# -*- encoding: utf-8 -*-
# stub: logtail 0.1.17 ruby lib

Gem::Specification.new do |s|
  s.name = "logtail".freeze
  s.version = "0.1.17".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/logtail/logtail-ruby/issues", "changelog_uri" => "https://github.com/logtail/logtail-ruby/tree/master/CHANGELOG.md", "homepage_uri" => "https://github.com/logtail/logtail-ruby", "source_code_uri" => "https://github.com/logtail/logtail-ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Better Stack".freeze]
  s.date = "2025-03-10"
  s.email = ["hello@betterstack.com".freeze]
  s.homepage = "https://github.com/logtail/logtail-ruby".freeze
  s.licenses = ["ISC".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Query logs like you query your database. https://logs.betterstack.com/".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<msgpack>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<bundler-audit>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rails_stdout_logging>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4".freeze])
  s.add_development_dependency(%q<rspec-its>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 2.3".freeze])
end

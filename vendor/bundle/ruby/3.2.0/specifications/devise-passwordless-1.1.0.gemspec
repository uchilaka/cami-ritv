# -*- encoding: utf-8 -*-
# stub: devise-passwordless 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "devise-passwordless".freeze
  s.version = "1.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/devise-passwordless/devise-passwordless", "source_code_uri" => "https://github.com/devise-passwordless/devise-passwordless" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Abe Voelker".freeze, "Jennifer Konikowski".freeze]
  s.date = "2025-04-13"
  s.email = ["_@abevoelker.com".freeze, "passwordless@jmkoni.com".freeze]
  s.homepage = "https://github.com/devise-passwordless/devise-passwordless".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\n  Devise Passwordless v1.0 introduces major, backwards-incompatible changes!\n  Please see https://github.com/devise-passwordless/devise-passwordless/blob/main/UPGRADING.md\n  for a guide on upgrading, or CHANGELOG.md for a list of changes.\n  ".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Passwordless (email-only) login strategy for Devise".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<devise>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<globalid>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<standard>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0".freeze])
end

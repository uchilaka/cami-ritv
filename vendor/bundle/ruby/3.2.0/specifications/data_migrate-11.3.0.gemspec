# -*- encoding: utf-8 -*-
# stub: data_migrate 11.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "data_migrate".freeze
  s.version = "11.3.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrew J Vargo".freeze, "Ilya Katz".freeze, "Deborah Enomah".freeze]
  s.date = "2025-03-19"
  s.description = "Rake tasks to migrate data alongside schema changes.".freeze
  s.email = ["ajvargo@computer.org".freeze, "ilyakatz@gmail.com".freeze, "enomaomorogieva@gmail.com".freeze]
  s.homepage = "https://github.com/ilyakatz/data-migrate".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Rake tasks to migrate data alongside schema changes.".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.1".freeze])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 6.1".freeze])
  s.add_development_dependency(%q<appraisal>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec-core>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rb-readline>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<overcommit>.freeze, [">= 0".freeze])
end

# -*- encoding: utf-8 -*-
# stub: capistrano-rails 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "capistrano-rails"
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tom Clements", "Lee Hambley"]
  s.date = "2014-01-15"
  s.description = "Rails specific Capistrano tasks"
  s.email = ["seenmyfate@gmail.com", "lee.hambley@gmail.com"]
  s.homepage = "https://github.com/capistrano/rails"
  s.rubygems_version = "2.4.6"
  s.summary = "Rails specific Capistrano tasks"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, ["~> 3.1"])
      s.add_runtime_dependency(%q<capistrano-bundler>, ["~> 1.1"])
    else
      s.add_dependency(%q<capistrano>, ["~> 3.1"])
      s.add_dependency(%q<capistrano-bundler>, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<capistrano>, ["~> 3.1"])
    s.add_dependency(%q<capistrano-bundler>, ["~> 1.1"])
  end
end

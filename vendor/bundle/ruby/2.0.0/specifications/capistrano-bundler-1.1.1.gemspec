# -*- encoding: utf-8 -*-
# stub: capistrano-bundler 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "capistrano-bundler"
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tom Clements", "Lee Hambley", "Kir Shatrov"]
  s.date = "2013-11-29"
  s.description = "Bundler support for Capistrano 3.x"
  s.email = ["seenmyfate@gmail.com", "lee.hambley@gmail.com", "shatrov@me.com"]
  s.homepage = "https://github.com/capistrano/bundler"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.6"
  s.summary = "Bundler support for Capistrano 3.x"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, ["~> 3.0"])
      s.add_runtime_dependency(%q<sshkit>, [">= 1.2.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<capistrano>, ["~> 3.0"])
      s.add_dependency(%q<sshkit>, [">= 1.2.0"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<capistrano>, ["~> 3.0"])
    s.add_dependency(%q<sshkit>, [">= 1.2.0"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end

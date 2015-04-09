# -*- encoding: utf-8 -*-
# stub: capistrano 3.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "capistrano"
  s.version = "3.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tom Clements", "Lee Hambley"]
  s.date = "2014-01-14"
  s.description = "Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH."
  s.email = ["seenmyfate@gmail.com", "lee.hambley@gmail.com"]
  s.executables = ["cap", "capify"]
  s.files = ["bin/cap", "bin/capify"]
  s.homepage = "http://capistranorb.com/"
  s.licenses = ["MIT"]
  s.post_install_message = "Capistrano 3.1 has some breaking changes, like `deploy:restart` callback should be added manually to your deploy.rb. Please, check the CHANGELOG: http://goo.gl/SxB0lr\n\nIf you're upgrading Capistrano from 2.x, we recommend to read the upgrade guide: http://goo.gl/4536kB\n"
  s.rubygems_version = "2.4.6"
  s.summary = "Capistrano - Welcome to easy deployment with Ruby over SSH"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sshkit>, ["~> 1.3"])
      s.add_runtime_dependency(%q<rake>, [">= 10.0.0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<sshkit>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 10.0.0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<sshkit>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 10.0.0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end

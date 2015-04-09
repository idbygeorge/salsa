# -*- encoding: utf-8 -*-
# stub: sshkit 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sshkit"
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lee Hambley", "Tom Clements"]
  s.date = "2013-12-19"
  s.description = "A comprehensive toolkit for remotely running commands in a structured manner on groups of servers."
  s.email = ["lee.hambley@gmail.com", "seenmyfate@gmail.com"]
  s.homepage = "http://github.com/capistrano/sshkit"
  s.licenses = ["GPL3"]
  s.rubygems_version = "2.4.6"
  s.summary = "SSHKit makes it easy to write structured, testable SSH commands in Ruby"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<net-ssh>, [">= 0"])
      s.add_runtime_dependency(%q<net-scp>, [">= 1.1.2"])
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["< 2.12.0", ">= 2.11.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<turn>, [">= 0"])
      s.add_development_dependency(%q<unindent>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<net-ssh>, [">= 0"])
      s.add_dependency(%q<net-scp>, [">= 1.1.2"])
      s.add_dependency(%q<term-ansicolor>, [">= 0"])
      s.add_dependency(%q<minitest>, ["< 2.12.0", ">= 2.11.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<turn>, [">= 0"])
      s.add_dependency(%q<unindent>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 0"])
    s.add_dependency(%q<net-scp>, [">= 1.1.2"])
    s.add_dependency(%q<term-ansicolor>, [">= 0"])
    s.add_dependency(%q<minitest>, ["< 2.12.0", ">= 2.11.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<turn>, [">= 0"])
    s.add_dependency(%q<unindent>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end

# -*- encoding: utf-8 -*-
# stub: arel 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "arel"
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Aaron Patterson", "Bryan Halmkamp", "Emilio Tagua", "Nick Kallen"]
  s.date = "2013-04-18"
  s.description = "Arel is a SQL AST manager for Ruby. It\n\n1. Simplifies the generation of complex SQL queries\n2. Adapts to various RDBMS systems\n\nIt is intended to be a framework framework; that is, you can build your own ORM\nwith it, focusing on innovative object and collection modeling as opposed to\ndatabase compatibility and query generation."
  s.email = ["aaron@tenderlovemaking.com", "bryan@brynary.com", "miloops@gmail.com", "nick@example.org"]
  s.extra_rdoc_files = ["History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.markdown"]
  s.files = ["History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.markdown"]
  s.homepage = "http://github.com/rails/arel"
  s.rdoc_options = ["--main", "README.markdown"]
  s.rubyforge_project = "arel"
  s.rubygems_version = "2.4.6"
  s.summary = "Arel is a SQL AST manager for Ruby"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 4.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.5"])
    else
      s.add_dependency(%q<minitest>, ["~> 4.4"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.5"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 4.4"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.5"])
  end
end

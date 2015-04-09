# -*- encoding: utf-8 -*-
# stub: awesome_nested_set 3.0.0.rc.3 ruby lib

Gem::Specification.new do |s|
  s.name = "awesome_nested_set"
  s.version = "3.0.0.rc.3"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Brandon Keepers", "Daniel Morrison", "Philip Arndt"]
  s.date = "2013-12-18"
  s.description = "An awesome nested set implementation for Active Record"
  s.email = "info@collectiveidea.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "http://github.com/collectiveidea/awesome_nested_set"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.md", "--inline-source", "--line-numbers"]
  s.rubygems_version = "2.4.6"
  s.summary = "An awesome nested set implementation for Active Record"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["< 5", ">= 4.0.0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.12"])
      s.add_development_dependency(%q<rake>, ["~> 10"])
      s.add_development_dependency(%q<combustion>, [">= 0.3.3"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, ["< 5", ">= 4.0.0"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.12"])
      s.add_dependency(%q<rake>, ["~> 10"])
      s.add_dependency(%q<combustion>, [">= 0.3.3"])
      s.add_dependency(%q<database_cleaner>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["< 5", ">= 4.0.0"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.12"])
    s.add_dependency(%q<rake>, ["~> 10"])
    s.add_dependency(%q<combustion>, [">= 0.3.3"])
    s.add_dependency(%q<database_cleaner>, [">= 0"])
  end
end

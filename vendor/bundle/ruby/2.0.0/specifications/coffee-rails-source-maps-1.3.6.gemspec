# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "coffee-rails-source-maps"
  s.version = "1.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Bates"]
  s.date = "2013-06-26"
  s.description = "Adds support to Rails for CoffeeScript Source Maps"
  s.email = ["mark@markbates.com"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.6"
  s.summary = "Adds support to Rails for CoffeeScript Source Maps"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coffee-script-source>, [">= 1.6.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<coffee-script-source>, [">= 1.6.1"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<coffee-script-source>, [">= 1.6.1"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end

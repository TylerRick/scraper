# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scraper/version"

Gem::Specification.new do |s|
  s.name        = "scraper"
  s.version     = Scraper::Version
  s.authors     = ["Tyler Rick"]
  s.email       = ["tyler@tylerrick.com"]
  s.homepage    = "http://github.com/TylerRick/scraper"
  s.summary     = %q{A ruby scraping library using Mechanize}
  s.description = s.summary

  s.add_dependency 'mechanize'
  s.add_dependency 'activesupport'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

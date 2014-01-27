# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kml_buddy/version'

Gem::Specification.new do |spec|
  spec.name          = "kml_buddy"
  spec.version       = KmlBuddy::VERSION
  spec.authors       = ["Omar Qazi", "Cotter Phinney"]
  spec.email         = ["omar@predpol.com", "cotter@predpol.com"]
  spec.summary       = %q{Some helpful functions for working with KML and KMZ}
  spec.description   = %q{A helpful little library for dealing with KML and KMZ files from your friends at PredPol}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency 'nokogiri'
end

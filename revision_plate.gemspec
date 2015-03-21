# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'revision_plate/version'

Gem::Specification.new do |spec|
  spec.name          = "revision_plate"
  spec.version       = RevisionPlate::VERSION
  spec.authors       = ["Shota Fukumori (sora_h)"]
  spec.email         = ["sorah@cookpad.com"]
  spec.summary       = %q{Rack middleware and application to show deployed application's revision (commit)}
  spec.description   = nil
  spec.homepage      = "https://github.com/sorah/revision_plate"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.7.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.5.1"
  spec.add_development_dependency "rack-test", "~> 0.6.3"

  spec.add_dependency "rack"
end

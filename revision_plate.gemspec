# coding: utf-8
require_relative 'lib/revision_plate/version'

Gem::Specification.new do |spec|
  spec.name          = "revision_plate"
  spec.version       = RevisionPlate::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["her@sorah.jp"]
  spec.summary       = %q{Rack middleware and application to show deployed application's revision (commit)}
  spec.description   = nil
  spec.homepage      = "https://github.com/sorah/revision_plate"
  spec.license       = "MIT"


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.5"
  spec.add_development_dependency "rack-test", "~> 2.2"

  spec.add_dependency "rack"
end

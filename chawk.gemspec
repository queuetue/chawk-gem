# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chawk/version'

Gem::Specification.new do |spec|
  spec.name          = "chawk"
  spec.version       = Chawk::VERSION
  spec.authors       = ["Scott Russell"]
  spec.email         = ["queuetue@gmail.com"]
  spec.summary       = %q{Interface to Chawk Server}
  spec.description   = %q{Interface to Chawk Server}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end

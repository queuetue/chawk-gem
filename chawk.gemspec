# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chawk/version'

Gem::Specification.new do |spec|
  spec.name          = "chawk"
  spec.version       = Chawk::VERSION
  spec.authors       = ["Scott Russell"]
  spec.email         = ["queuetue@gmail.com"]
  spec.summary       = %q{Time Series Storage Server}
  spec.description   = %q{Time Series Storage Server}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "dm-sqlite-adapter", "1.2.0"
  spec.add_runtime_dependency "dm-postgres-adapter","1.2.0"
  spec.add_runtime_dependency "data_mapper", "1.2.0"
  spec.add_runtime_dependency "dm-is-tree", "1.2.0"
  spec.add_runtime_dependency "dm-aggregates", "1.2.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('minitest', '5.3.0')
  spec.add_development_dependency('rack-test', "0.6.2")
  spec.add_development_dependency('json', "1.8.1")
  spec.add_development_dependency('coveralls', "0.7.0")


end

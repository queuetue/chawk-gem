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

  spec.add_runtime_dependency "sqlite3", "~> 1.3.9"
  spec.add_runtime_dependency "dm-sqlite-adapter"
  spec.add_runtime_dependency "dm-postgres-adapter"
  spec.add_runtime_dependency "data_mapper"
  spec.add_runtime_dependency "dm-is-tree"
  spec.add_runtime_dependency "dm-aggregates"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('haml', '~> 4.0.4')
  spec.add_development_dependency('minitest', '~> 5.2.0')
  spec.add_development_dependency('mocha', '~> 0.14.0')
  spec.add_development_dependency('fakeweb', '~> 1.3.0')
  spec.add_development_dependency('simplecov', '~> 0.8.2')
  spec.add_development_dependency('rack-test')
  spec.add_development_dependency('json')

end

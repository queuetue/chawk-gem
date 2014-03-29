# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chawk/version'

Gem::Specification.new do |spec|
  spec.name          = "chawk"
  spec.version       = Chawk::VERSION
  spec.authors       = ["Scott Russell"]
  spec.email         = ["queuetue@gmail.com"]
  spec.summary       = %q{Time Series Storage Engine}
  spec.description   = %q{A storage engine for time-series data.  Eventually to include resampling, statistical and aggregate data management.}
  spec.homepage      = "http://www.queuetue.com/Chawk"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency('activerecord',"4.0.4")
  
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('rack-test', "0.6.2")
  spec.add_development_dependency('json', "1.8.1")
  spec.add_development_dependency('simplecov', "0.8.2")
  spec.add_development_dependency('pg', "0.17.1")
  spec.add_development_dependency('sqlite3', "1.3.9")
  #spec.add_development_dependency('pry')
  #spec.add_development_dependency('pry-debugger')
  #spec.add_development_dependency('pry-stack_explorer')
end

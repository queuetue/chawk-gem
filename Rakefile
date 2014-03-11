#require "bundler/gem_tasks"
#require "rspec/core/rake_task"
require 'rake/testtask'

#RSpec::Core::RakeTask.new

#task :default => :spec
#task :test => :spec

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
end

task :default => [:test]
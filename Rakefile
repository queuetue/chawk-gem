require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
end

# TODO: Implement PG tests
# Rake::TestTask.new(:pg_test) do |test|
#   test.libs << 'lib' << 'test'
#   test.pattern = 'test_pg/**/*_test.rb'
# end


task :default => [:test]
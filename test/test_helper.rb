# require 'pp'
# require 'pry'
# require 'pry-stack_explorer'
# require 'pry-debugger'
require 'simplecov'

SimpleCov.start do
  add_filter "/test/"
end

require 'chawk'

require 'rack/test'
require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/chawk'

ENV['RACK_ENV'] = 'test'
WORKING_DIRECTORY = Dir.pwd.freeze
ARGV.clear

ENV["CHAWK_DEBUG"] ? debug_level=ENV["CHAWK_DEBUG"] : debug_level=:info

#if ENV["TEST_DATABASE_LOG"]
#  ActiveRecord::Base.logger = Logger.new(STDOUT)
#end

require 'active_record'
require 'yaml'

if ENV["TEST_DATABASE_URLX"]
  ActiveRecord::Base.establish_connection ENV["TEST_DATABASE_URL"]
else
  ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
  ActiveRecord::Migration.verbose = false
  require "chawk/migration"
  CreateChawkBase.migrate :up
  CreateChawkBase.migrate :down # I'm surprised what I'll do to increase coverage.
  CreateChawkBase.migrate :up
  File.open('./test/schema.rb', "w") do |file|
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
  end
end


load File.dirname(__FILE__) + '/schema.rb'
require File.dirname(__FILE__) + '/../lib/models.rb'

Chawk.clear_all_data!

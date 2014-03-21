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
#	DataMapper::Logger.new(ENV["TEST_DATABASE_LOG"], debug_level)
#else
#	DataMapper::Logger.new($stdout, debug_level)
#end




#if ENV["TEST_DATABASE_URL"]
#	Chawk.setup ENV["TEST_DATABASE_URL"]
#else
#	Chawk.setup 'sqlite::memory:'
#	DataMapper.auto_upgrade!
#end

require 'active_record'
#ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection ENV["TEST_DATABASE_URL"]

load File.dirname(__FILE__) + '/schema.rb'
require File.dirname(__FILE__) + '/../lib/models.rb'


Chawk.clear_all_data!

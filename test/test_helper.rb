#require 'simplecov'
#SimpleCov.start do
#  add_filter "/test/"
#end

require 'coveralls'
Coveralls.wear!

require 'chawk'

require 'rack/test'
require 'stringio'
require 'tmpdir'
require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/chawk'

ENV['RACK_ENV'] = 'test'
WORKING_DIRECTORY = Dir.pwd.freeze
ARGV.clear

DataMapper::Logger.new('db.log', :debug)
#DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true

DataMapper.logger.debug "Here we go!"

adapter = DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.finalize
DataMapper.auto_upgrade!

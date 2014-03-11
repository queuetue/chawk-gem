require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end
require 'chawk'

require 'rack/test'
require 'stringio'
require 'tmpdir'
require 'fakeweb'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/setup'

require_relative '../lib/chawk'

FakeWeb.allow_net_connect = false

ENV['RACK_ENV'] = 'test'
WORKING_DIRECTORY = Dir.pwd.freeze
ARGV.clear

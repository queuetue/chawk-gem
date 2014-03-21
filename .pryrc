$:.unshift('lib')

require 'active_record'
require 'hirb'
require 'chawk'


Hirb.enable
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection ENV["TEST_DATABASE_URL"]

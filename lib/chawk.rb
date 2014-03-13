require "chawk/version"
require 'data_mapper'
require 'dm-is-tree'
require 'quantizer'
require 'board'

module Chawk
	module DataPoint
		attr_reader :paddr, :value, :timestamp
		def initialize(vaddr, value)
			@vaddr = vaddr
			@value = value.value
			@timestamp = value.observed_at
		end
	end
end

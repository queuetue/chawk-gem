require 'models'
require 'addr'

module Chawk
	class Board
		attr_reader :points, :values
		def initialize
		end

		def addr(agent,path)
			Chawk::Addr.new(agent,path)
		end

	end
end
require 'models'
require 'addr'

module Chawk
	class Board
		attr_reader :points, :values
		def initialize
		end

		def addr(path)
			Chawk::Addr.new(path)
		end

	end
end
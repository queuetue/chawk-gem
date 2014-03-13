require 'addressable'
module Chawk
	module Store
		include Addressable
		attr_reader :board

		def initialize(board)
			@board = board
			@root_node = nil
		end

	end
end
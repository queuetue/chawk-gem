require 'addressable'
module Chawk
	module Store
		include Addressable
		attr_reader :board

		def addr_class
			raise NotImplementedError
		end

		def addr(path)
			addr_class.new(self,path)
		end

		def initialize(board)
			@board = board
			@root_node = nil
		end

		def root_node()
			if @root_node.nil?
				@root_node = find_or_create_node nil,"ROOT"
			end
			@root_node
		end
	end
end
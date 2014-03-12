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

			#Chawk::Vaddr.new(self,path)
			#find_or_create_addr path
		end

		def initialize(board)
			@board = board
			@root_node = nil
		end

		def get_pointer(path)
			Vaddr.new(self, path)
		end

		def root_node()
			if @root_node.nil?
				@root_node = find_or_create_node nil,"ROOT"
			end
			@root_node
		end
	end
end
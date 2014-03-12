require 'store'
require 'vaddr'

module Chawk
	class ValueStore
		include Chawk::Store

		def addr_class
			Chawk::Vaddr
		end

		def model
			Chawk::Models::ValueNode
		end

	end
end
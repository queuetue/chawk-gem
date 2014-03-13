require 'store'
require 'vaddr'

module Chawk
	class ValueStore
		include Chawk::Store

		def addr_class
			Chawk::Vaddr
		end

	end
end
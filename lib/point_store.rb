require 'store'
require 'paddr'

module Chawk
	class PointStore
		include Chawk::Store
		def addr_class
			Chawk::Paddr
		end

		def model
			Chawk::Models::PointNode
		end

	end
end
require 'store'
require 'paddr'

module Chawk
	class PointStore
		include Chawk::Store

		def root_name
			"PROOT"
		end
	end
end
require 'store'

module Chawk
	class Vaddr

		include Chawk::Store

		def coll
			@node.values
		end

		def model
			Chawk::Models::Value
		end

		def stored_type
			String
		end
	end

end
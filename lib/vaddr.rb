require 'store'

module Chawk
	# The Value Store - where time series string data is stored and retrieved through an instance of Chawk::Addr.
	class Vaddr

		include Chawk::Store

private
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
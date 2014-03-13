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

	class VValue
		attr_reader :paddr, :value, :timestamp
		def initialize(vaddr, value)
			@vaddr = vaddr
			@value = value.value
			@timestamp = value.observed_at
		end

		def to_s
			to_str
		end
		def to_str
			@value
		end
	end

end
require 'store'

module Chawk
	class Paddr

		include Chawk::Store

		def model
			Chawk::Models::Point
		end

		def coll
			@node.points
		end

		def stored_type
			Integer
		end

		def +(other = 1)
			raise ArgumentError unless other.is_a?(Numeric) && other.integer?
			int = (self.last.value.to_i + other.to_i)
			self << int
		end  

		def -(other = 1)
			self + (-other)
		end  

		  def length
			coll.length
		end

		def max
			coll.max(:value)
		end

		def min
			coll.min(:value)
		end

	end

	class PPoint
		attr_reader :paddr, :value, :timestamp
		def initialize(vaddr, value)
			@vaddr = vaddr
			@value = value.value
			@timestamp = value.observed_at
		end

		def to_i
			@value
		end
		def to_int
			@value
		end

		def to_s
			@value.to_s
		end

		def to_str
			@value.to_s
		end
	end

end
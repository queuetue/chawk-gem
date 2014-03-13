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
			raise ArgumentError unless other.is_a?(Numeric) && other.integer?
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

end
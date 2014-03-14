require 'store'

module Chawk

	# The Point Store - where time series integer data is stored, retrieved and aggregated through an instance of Chawk::Addr.
	class Paddr

		include Chawk::Store

		# @param other [Integer] the integer to add to the value at this address.
		# Increment the most recent point observed at this address.  The most recent observed is 
		# not necessarily the most recent stored, as data can arrive out of order.

		def +(other = 1)
			raise ArgumentError unless other.is_a?(Numeric) && other.integer?
			int = (self.last.value.to_i + other.to_i)
			self << int
		end  

		# @param other [Integer] the integer to subtract to the value at this address.
		# Decrement the most recent point observed at this address.  The most recent observed is 
		# not necessarily the most recent stored, as data can arrive out of order.
		def -(other = 1)
			raise ArgumentError unless other.is_a?(Numeric) && other.integer?
			self + (-other)
		end  

		  def length
			coll.length
		end

		# @return [Integer] the largest value stored.
		# Returns the largest value currently stored at this address.
		def max
			coll.max(:value)
		end

		# @return [Integer] the smallest value stored.
		# Returns the smallest value currently stored at this address.
		def min
			coll.min(:value)
		end
private

		def model
			Chawk::Models::Point
		end

		def coll
			@node.points
		end

		def stored_type
			Integer
		end

	end

end
module Chawk
	class SqlitePoint
		attr_reader :pointer, :value, :timestamp
		def initialize(pointer, value,timestamp)
			@pointer = pointer
			@value = value
			@timestamp = timestamp
		end

		def inspect  
			"#{@value}#Point"  
		end  
	end
end
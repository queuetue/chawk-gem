module Chawk
	class SqlitePoint
		attr_reader :pointer, :value, :timestamp
		def initialize(pointer, value,timestamp)
			@pointer = pointer
			@value = value
			@timestamp = timestamp
		end

		def to_s  
			"#{@value}:#{@timestamp}#Point"  
		end  

		def inspect  
			"#{@value}:#{@timestamp}#Point"  
		end  
	end
end
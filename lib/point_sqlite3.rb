module Chawk
	class SqlitePoint
		attr_reader :pointer, :value, :timestamp, :source
		def initialize(pointer, value,options={})
			@pointer = pointer
			@value = value
			@timestamp = Time.now()
			if options[:source]
				@source = options[:source]
			end
		end

		def inspect  
			"#{@value}#Point"  
		end  
	end
end
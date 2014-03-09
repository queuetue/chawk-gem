require "chawk/version"

module Chawk
	class Point
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
	class Pointer
	  attr_accessor :path
	  def initialize(path)
		unless path.is_a?(Array)
			raise ArgumentError
			self.delete
		end

		unless path.reject{|x|x.is_a?(String)}.empty?
			raise ArgumentError
			self.delete
		end

		unless path.select{|x|x.include?('/')}.empty?
			raise ArgumentError
			self.delete
		end

	    @path = path
	    #puts "PATH: #{path}"
	    @history = []#(1..25).collect{|x|rand(100)}
	  end


	  def address
	    @path.join("/")
	  end

	  def +(other = 1)
	  	raise ArgumentError unless other.integer?
	  	self << self.last.value + other
	  end  

	  def -(other = 1)
	  	raise ArgumentError unless other.integer?
	  	self << self.last.value - other
	  end  

	  def <<(args)
	  	if args.is_a?(Array)
			#puts "ARGS: #{args}"
	  		args.each do |arg|
	  			if arg.is_a?(Integer)
	  				p = Point.new(self,arg)
	  				@history << p
	  			else
	  				#puts "ARGS/ARG ERROR: #{arg}"
	  				raise ArgumentError
	  			end
	  		end
	  	else
			if args.is_a?(Integer)
				p = Point.new(self,args)
	  			@history << p
			else
	  			#puts "ARG ERROR: #{arg}"
  				raise ArgumentError
  			end
	  	end
	  	self.last
	  end

	  def last
	  	return @history[-1]
	  end

	  def clear_history!
	  	@history.clear
	  end

	  def length
	  	@history.length
	  end

	  def max
	  	@history.max_by{|a|a.value}
	  end

	  def min
	  	@history.min_by{|a|a.value}
	  end

	end
end

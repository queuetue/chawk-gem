require "chawk/version"

module Chawk
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
	    @history = (1..25).collect{|x|rand(100)}
	  end


	  def address
	    @path.join("/")
	  end

	  def <<(args)
	  	if args.is_a?(Array)
			#puts "ARGS: #{args}"
	  		args.each do |arg|
	  			if arg.is_a?(Integer)
	  				@history << arg
	  			else
	  				#puts "ARGS/ARG ERROR: #{arg}"
	  				raise ArgumentError
	  			end
	  		end
	  	else
			if args.is_a?(Integer)
	  			@history << args
			else
	  			#puts "ARG ERROR: #{arg}"
  				raise ArgumentError
  			end
	  	end
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
	  	@history.max
	  end

	  def min
	  	@history.min
	  end

	end
end

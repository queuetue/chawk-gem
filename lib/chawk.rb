require "chawk/version"

module Chawk
	class Pointer
	  attr_accessor :path
	  def initialize(*path)
	    @path = path
	    @history = (1..25).collect{|x|rand(100)}
	  end
	  def address
	    @path.join("/")
	  end

	  def <<(*args)
	  	if args.is_a?(Array)
	  		args.each do |arg|
	  			if arg.is_a?(Integer)
	  				@history << arg
	  			else
	  				raise ArgumentError
	  			end
	  		end
	  	else
			if args.is_a?(Integer)
	  			@history << args
			else
  				raise ArgumentError
  			end
	  	end
	  end

	  def last
	  	return @history[-1]
	  end

	end
end

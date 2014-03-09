require "chawk/version"

module Chawk
	class Pointer
	  attr_accessor :path
	  def initialize(*path)
	    @path = path
	    @history = (1..5).collect{|x|8}
	  end
	  def address
	    @path.join("/")
	  end
	end
end

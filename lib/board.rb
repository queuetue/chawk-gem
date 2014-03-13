require 'models'
require 'addr'
#require 'value_store'
#require 'point_store'

module Chawk
	class Board
		attr_reader :points, :values
		def initialize
			#@points = PointStore.new self
			#@values = ValueStore.new self
		end

		def addr(path)
			Chawk::Addr.new(path)
		end

	end
end
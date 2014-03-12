require 'models'
require 'value_store'
require 'point_store'

module Chawk
	class Board
		attr_reader :points, :values
		def initialize
			@points = PointStore.new self
			@values = ValueStore.new self
		end
	end
end
require 'models'
require 'addr'

module Chawk
	class Board
		attr_reader :points, :values
		def initialize
		end

		def clear_all_data!
			Chawk::Models::Agent.all.destroy!
			Chawk::Models::Relation.all.destroy!
			Chawk::Models::AgentTag.all.destroy!
			Chawk::Models::Tag.all.destroy!
			Chawk::Models::Node.all.destroy!
			Chawk::Models::Point.all.destroy!
			Chawk::Models::Value.all.destroy!
		end

		def addr(agent,path)
			Chawk::Addr.new(agent,path)
		end

	end
end
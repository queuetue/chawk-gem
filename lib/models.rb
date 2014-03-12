require 'data_mapper'
require 'dm-is-tree'
require 'dm-aggregates'
module Chawk
	module Models
		class ValueNode
			include DataMapper::Resource
			property :id, Serial
			property :name, String
			is :tree, :order => :name
			has n, :values
		end

		class Value
			include DataMapper::Resource
			before :create, :set_timestamp

			property :id, Serial
			property :value, Integer
			property :observed_at, DateTime
			property :recorded_at, DateTime
			belongs_to :value_node

		    def set_timestamp
		    	attribute_set(:recorded_at, DateTime.now )
		    end
		end
	end
end
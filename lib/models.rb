require 'data_mapper'
require 'dm-is-tree'
require 'dm-aggregates'
module Chawk
	module Models

		module DataPoint
		    def self.included(base)
		      base.class_eval do
		        include DataMapper::Resource
				before :create, :set_timestamp

		        property :id, DataMapper::Property::Serial
				property :observed_at, DataMapper::Property::Float
				property :recorded_at, DataMapper::Property::DateTime
				belongs_to :node

				def set_timestamp
					attribute_set(:recorded_at, DateTime.now )
				end

		      end
		    end

		end

		class Node
			include DataMapper::Resource
			property :id, Serial
			property :name, String
			is :tree, :order => :name
			has n, :points
			has n, :values
		end

		class Point
			include Chawk::Models::DataPoint
			property :value, Integer
		end

		class Value
			include Chawk::Models::DataPoint
			property :value, Text
		end
	end
end
require 'data_mapper'
require 'dm-aggregates'
module Chawk
	module Models

		module Datum
		    def self.included(base)
		      base.class_eval do
		        include DataMapper::Resource
				before :create, :set_timestamp

		        property :id, DataMapper::Property::Serial
				property :observed_at, DataMapper::Property::Float
				property :recorded_at, DataMapper::Property::DateTime
				property :meta, DataMapper::Property::Text

				belongs_to :node
				belongs_to :agent

				def set_timestamp
					attribute_set(:recorded_at, DateTime.now )
				end

		      end
		    end

		end

		class Agent
			include DataMapper::Resource
			property :id, Serial
			property :foreign_id, Integer
			property :name, String, length:200
			has n, :tags
			has n, :agent_tags
			has n, :relations
		end

		class Relation
			include DataMapper::Resource
			property :id, Serial
			property :admin, Boolean
			property :read, Boolean
			property :write, Boolean
			belongs_to :agent
			belongs_to :node
		end

		class AgentTag
			include DataMapper::Resource
			property :id, Serial
			property :name, String, length:100
			property :description, Text
			property :managed, Boolean
			belongs_to :agent
		end

		class Tag
			include DataMapper::Resource
			property :description, Text
			property :id, Serial
			property :name, String, length:100
		end

		class Node
			include DataMapper::Resource
			property :id, Serial
			property :address, String, length:150
			property :public_read, Boolean
			property :public_write, Boolean

			has n, :points
			has n, :values
			has n, :relations
		end

		class Point
			include Chawk::Models::Datum
			property :value, Integer
		end

		class Value
			include Chawk::Models::Datum
			property :value, Text
		end
	end
end
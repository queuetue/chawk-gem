require 'data_mapper'
require 'dm-aggregates'
module Chawk
	# Models used in Chawk.  Most are DataMapper classes.
	module Models

		# Base stored item, imported into other DataMapper classes.
		module Datum

			protected

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

		# Agent DataMapper classes.
		# Contains a foreign_id for use as a proxy to another table.
		class Agent
			include DataMapper::Resource
			property :id, Serial
			property :foreign_id, Integer
			property :name, String, length:200
			has n, :tags
			has n, :agent_tags
			has n, :relations
		end

		# Agent Relation DataMapper classes, with permission flags.
		class Relation
			include DataMapper::Resource
			property :id, Serial
			property :admin, Boolean, default:false
			property :read, Boolean, default:false
			property :write, Boolean, default:false
			belongs_to :agent
			belongs_to :node
		end

		# Agent Tags.
		# Not implimented yet.
		class AgentTag
			include DataMapper::Resource
			property :id, Serial
			property :name, String, length:100
			property :description, Text
			property :managed, Boolean, default:false
			belongs_to :agent
		end

		# Item Tags.
		# Not implimented yet.
		class Tag
			include DataMapper::Resource
			property :description, Text
			property :id, Serial
			property :name, String, length:100
		end

		# The Node, where most Chawk:Addr information is persisted..
		class Node
			include DataMapper::Resource
			property :id, Serial
			property :address, String, length:150
			property :public_read, Boolean, default:false
			property :public_write, Boolean, default:false

			has n, :points
			has n, :values
			has n, :relations
		end

		# The Node, where most Chawk point information is persisted..
		class Point
			include Chawk::Models::Datum
			property :value, Integer
		end

		# The Node, where most Chawk value information is persisted..
		class Value
			include Chawk::Models::Datum
			property :value, Text
		end
	end
end
require 'active_record'
require 'node'
require 'range'
module Chawk
	# Models used in Chawk.  ActiveRecord classes.
	module Models

		# Contains a foreign_id for use as a proxy to another table.
		class Agent < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			has_many :tags
			has_many :agent_tags
			has_many :relations
			has_many :nodes, :through=>:relations
			has_many :read_relations, ->{where("read = ? OR admin = ?", true,true)}, :class_name=>"Chawk::Models::Relation"
			has_many :read_nodes, :through=>:read_relations, :source=>:node #, ->{where(read:true, admin:true)}
			has_many :write_relations, ->{where("write = ? OR admin = ?", true,true)}, :class_name=>"Chawk::Models::Relation"
			has_many :write_nodes, :through=>:write_relations, :source=>:node #, ->{where(read:true, admin:true)}
			has_many :admin_relations, ->{where(admin:true)}, :class_name=>"Chawk::Models::Relation"
			has_many :admin_nodes, :through=>:admin_relations, :source=>:node #, ->{where(read:true, admin:true)}
		end

		# Agent Relation classes, with permission flags.
		class Relation < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			belongs_to :agent
			belongs_to :node
		end

		# The Node, where most Chawk point information is persisted..
		class Point < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			belongs_to :node
		end

		# The Node, where most Chawk value information is persisted..
		class Value < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			belongs_to :node
		end

	end
end

require "chawk/version"
require "quantizer"
require "pointer_sqlite3"
require 'data_mapper'
require 'dm-is-tree'

module Chawk
	class Board
		attr_reader :point_store, :value_store, :paddr_root, :vaddr_root
		def initialize
			@points = PointStore.new
			@values = ValueStore.new
			@paddr_root = find_or_create_node nil,"PROOT"
			@vaddr_root = find_or_create_node nil,"VROOT"
		end

		def find_or_create_node(parent,name)
			#TODO: AUTHENTICATION / PERMISSIONS
			if parent.nil?
				node = Chawk::Node.create(name:name)
			else
				node = parent.children.first(name:name)
				node ? node : parent.children.create(name:name)
			end
			return node
		end
		def find_or_create_addr(addr)
			#TODO also accept regex-tested string
			raise ArgumentError unless addr.is_a?(Array)
			ary = Array(addr)
			parent = @root_node
			while ary.length > 0
				level = ary.shift
				parent = find_or_create_node(parent,level)
			end
			return parent
		end

		def get_vaddr(address)
		end

		def get_paddr(address)
		end

	end
	class ValueStore
	end
	class VAddr
	end
	class VValue
	end
	class VRange
	end

	class PointStore
	end
	class PAddr
	end
	class PPoint
	end
	class PRange
	end
	class PTrend
	end
	class PQuant
	end
	class Node
		include DataMapper::Resource
		property :id, Serial
		property :name, String
		is :tree, :order => :name			
	end

	class Datapoint
		include DataMapper::Resource
		before :create, :set_timestamp

		property :id, Serial
		property :value, Integer
		property :observed_at, DateTime
		property :recorded_at, DateTime
		belongs_to :node

	    def set_timestamp
	    	attribute_set(:recorded_at, DateTime.now )
	    end
	end
end

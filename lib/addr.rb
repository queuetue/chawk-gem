require 'vaddr'
require 'paddr'
module Chawk
	class Addr
		attr_reader :path, :node
		def initialize(path)
			@path = path

			unless path.is_a?(Array)
				raise ArgumentError
			end

			unless path.reject{|x|x.is_a?(String)}.empty?
				raise ArgumentError
			end

			unless path.select{|x|x !~ /^\w+$/}.empty?
				raise ArgumentError
			end

			@node = find_or_create_addr(path)

			unless @node
				raise ArgumentError
			end

		end

		def values()
			Chawk::Vaddr.new(self)
		end

		def points()
			Chawk::Paddr.new(self)
		end

		def root_node()
			if @root_node.nil?
				@root_node = find_or_create_node nil,"ROOT"
			end
			@root_node
		end

		def find_or_create_node(parent,name)
			#TODO: AUTHENTICATION / PERMISSIONS
			if parent.nil?
				node = Chawk::Models::Node.first(parent:nil,name:name)
				node = Chawk::Models::Node.create(name:name) if node.nil?
			else
				node = parent.children.first(name:name)
				node ? node : node = parent.children.create(name:name)
			end
			return node
		end

		def find_or_create_addr(addr)
			#TODO also accept regex-tested string
			raise ArgumentError unless addr.is_a?(Array)
			ary = addr.dup
			parent = root_node
			while ary.length > 0
				level = ary.shift
				parent = find_or_create_node(parent,level)
			end
			return parent
		end

		def address
			@path.join("/")
		end
	end
end
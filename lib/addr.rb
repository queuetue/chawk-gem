require 'vaddr'
require 'paddr'
module Chawk
	class Addr
		attr_reader :path, :node
		def initialize(agent,path)
			@path = path
			@agent = agent

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

		def public_read=(value,options={})

			value = value ? true : false

			while @node != @root_node
				@node = @node.parent
				DataMapper.logger.debug "MAKING #{@node.name} PUBLIC"
				@node.update(public_read:value)
			end
		end

		def find_or_create_node(parent,name)
			#TODO: AUTHENTICATION / PERMISSIONS
			if parent.nil?
				node = Chawk::Models::Node.first(parent:nil,name:name)
				node = Chawk::Models::Node.create(name:name) if node.nil?
				return node
			else
				node = parent.children.first(name:name)
				if node
					if node.public_read
						DataMapper.logger.debug "NODE IS PUBLIC ACCESSABLE -- #{@agent.name} - #{@agent.id}"
						return node
					end
					rel = node.relations.first(agent:@agent)
					if (rel && (rel.read || rel.admin))
						DataMapper.logger.debug "NODE IS ACCESSABLE -- #{@agent.name} - #{@agent.id}"
						return node
					else
						DataMapper.logger.debug "NODE IS INACCESSABLE -- #{@agent.name} - #{@agent.id}"
						raise SecurityError
					end
				else
					DataMapper.logger.debug "NODE CREATED -- #{@agent.name} -- #{@agent.id}"
					node = parent.children.create(name:name,public_read:false,public_write:false)
					node.relations.create(agent:@agent,node:node,admin:true,read:true,write:true)
					return node
				end
			end
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
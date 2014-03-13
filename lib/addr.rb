require 'vaddr'
require 'paddr'
module Chawk
	class Addr
		attr_reader :path, :node, :agent
		def initialize(agent,path)
			@path = path
			@agent = agent

			unless path.is_a?(String)
				DataMapper.logger.debug "NOT A STRING"
				raise ArgumentError
			end

			unless path =~ /^[\w\/\:\\]+$/
				DataMapper.logger.debug "BAD MATCH"
				raise ArgumentError
			end

			@node = find_or_create_addr(path)

			unless @node
				DataMapper.logger.debug "NOT A NODE"
				raise ArgumentError
			end
		end

		def address
			@path
		end


		def values()
			Chawk::Vaddr.new(self)
		end

		def points()
			Chawk::Paddr.new(self)
		end

		def public_read=(value,options={})
			value = value ? true : false
			DataMapper.logger.debug "MAKING #{@node.name} PUBLIC"
			@node.update(public_read:value)
		end

		def check_node_security(node)
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
		end

		def find_or_create_addr(addr)
			#TODO also accept regex-tested string
			raise ArgumentError unless addr.is_a?(String)

			node = Chawk::Models::Node.first(address:self.address)
			if node
				node = check_node_security(node)
			else
				DataMapper.logger.debug "NODE CREATED -- #{@agent.name} -- #{@agent.id}"
				node = Chawk::Models::Node.create(address:self.address) if node.nil?
				node.relations.create(agent:@agent,node:node,admin:true,read:true,write:true)
				return node
			end
		end

	end
end
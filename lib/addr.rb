require 'vaddr'
require 'paddr'
module Chawk
	# Manages addressing of Nodes - all data operations in Chawk are done 
	# through an instance of Chawk::Addr.
	class Addr
		attr_reader :key, :node, :agent

		# @param agent [Chawk::Agent] the agent whose permission will be used for this request 
		# @param key [String] the string address this addr can be found in the database.
		# If a key does not exist, it will be created and the current agent will be set as an admin for it.
		def initialize(agent,key)
			@key = key
			@agent = agent

			unless key.is_a?(String)
				raise 	entError, "Key must be a String."
			end

			unless key =~ /^[\w\:\$\!\@\*\[\]\~\(\)]+$/
				raise ArgumentError, "Key can only contain [A-Za-z0-9_:$!@*[]~()] (#{path})"
			end

			@node = find_or_create_node(key)

			unless @node
				raise ArgumentError,"No node returned."
			end
		end

		# Returns the Value Store at this address
		# @return [Chawk::Vaddr]
		def values()
			Chawk::Vaddr.new(self)
		end

		# Returns the Point Store at this address
		# @return [Chawk::Paddr]
		def points()
			Chawk::Paddr.new(self)
		end

		# Sets public read flag for this address 
		# @param value [Boolean] true if public reading is allowed, false if it is not.
		def public_read=(value)
			value = value ? true : false
			#DataMapper.logger.debug "MAKING #{@node.address} PUBLIC (#{value})"
			@node.update(public_read:value)
		end

		# Sets permissions flag for this address, for a specific agent.  The existing Chawk::Relationship will be destroyed and 
		# a new one created as specified.  Write access is not yet checked.
		# @param agent [Chawk::Agent] the agent to give permission.
		# @param read [Boolean] true/false can the agent read this address.
		# @param write [Boolean] true/false can the agent write this address. (Read acces is required to write.)
		# @param admin [Boolean] does the agent have ownership/adnim rights for this address. (Read and write are granted if admin is as well.)
		def set_permissions(agent,read=false,write=false,admin=false)
			#DataMapper.logger.debug "REVOKING #{@node.address} / #{@agent.name} "
			@node.relations.all(agent:agent).destroy()
			if read || write || admin
				vals = {agent:agent,read:(read ? true : false),write:(write ? true : false),admin:(admin ? true : false)}
				#DataMapper.logger.debug "SET PERMISSIONS #{@node.address} / #{vals} "
				@node.relations.create(vals)
			end
			nil
		end

private

		# def check_node_security(node)
		# 	if node.public_read
		# 		#DataMapper.logger.debug "NODE IS PUBLIC ACCESSABLE -- #{@agent.name} - #{@agent.id}"
		# 		return node
		# 	end
		# 	rel = node.relations.where(agent:@agent).first
		# 	if (rel && (rel.read || rel.admin))
		# 		#DataMapper.logger.debug "NODE IS ACCESSABLE -- #{@agent.name} - #{@agent.id}"
		# 	return node
		# 	else
		# 		#DataMapper.logger.debug "NODE IS INACCESSABLE -- #{@agent.name} - #{@agent.id}"
		# 		raise SecurityError,"You do not have permission to access this node. #{@agent}"
		# 	end
		# end

		# def find_or_create_node(key)
		# 	#TODO also accept regex-tested string
		# 	raise(ArgumentError,"Key must be a string.") unless key.is_a?(String)

		# 	node = Chawk::Models::Node.where(key:self.key).first
		# 	if node
		# 		node = check_node_security(node)
		# 	else
		# 		#DataMapper.logger.debug "NODE CREATED -- #{@agent.name} -- #{@agent.id}"
		# 		node = Chawk::Models::Node.create(key:self.key) if node.nil?
		# 		node.relations.create(agent:@agent,node:node,admin:true,read:true,write:true)
		# 		return node
		# 	end
		# end

	end
end
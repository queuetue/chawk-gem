require "chawk/version"
require 'quantizer'
require 'models'

# Chawk is a gem for storing and retrieving time seris data.
module Chawk

	# Has Chawk been setup yet?
	#@@ready = nil

	def self.check_node_security(agent,node)

		if node.public_read
			return node
		end

		rel = node.relations.where(agent:agent).first

		if (rel && (rel.read || rel.admin))
			return node
		else
			raise SecurityError,"You do not have permission to access this node. #{agent} #{rel}"
		end
	end

	def self.find_or_create_node(agent,key)
		#TODO also accept regex-tested string
		raise(ArgumentError,"Key must be a string.") unless key.is_a?(String)

		node = Chawk::Models::Node.where(key:key).first
		if node
			node = check_node_security(agent,node)
		else
			#DataMapper.logger.debug "NODE CREATED -- #{@agent.name} -- #{@agent.id}"
			node = Chawk::Models::Node.create(key:key) if node.nil?
			node.relations.create(agent:agent,node:node,admin:true,read:true,write:true)
			return node
		end
	end

	# @param agent [Chawk::Agent] the agent whose permission will be used for this request 
	# @param key [String] the string address this addr can be found in the database.
	# @return [Chawk::Addr]
	# The primary method for retrieving an Addr.  If a key does not exist, it will be created 
	# and the current agent will be set as an admin for it.
	def self.addr(agent,key)

		unless key =~ /^[\w\:\$\!\@\*\[\]\~\(\)]+$/
			raise ArgumentError, "Key can only contain [A-Za-z0-9_:$!@*[]~()] (#{key})"
		end

		unless agent.is_a?(Chawk::Models::Agent) 
			raise ArgumentError, 'Agent must be a Chawk::Models::Agent instance'
		end

		unless key.is_a?(String)
			raise ArgumentError, 'key must be a string.'
		end

		node = find_or_create_node(agent,key)

		unless node
			raise ArgumentError,"No node was returned."
		end

		node.agent = agent
		return node
	end

	# @param agent [Chawk::Agent] the agent whose permission will be used for this request 
	# @param data [Hash] the bulk data to be inserted
	# Insert data for multiple addresses at once.  Format should be a hash of valid data sets keyed by address 
	# example: {'key1'=>[1,2,3,4,5],'key2'=>[6,7,8,9]}   
	def self.bulk_add_points(agent, data)
		data.keys.each do |key|
			dset = data[key]
			daddr = addr(agent,key)
			daddr.add_points dset
		end
	end


	# Deletes all data in the database.  Very dangerous.  Backup often!
	def self.clear_all_data!
		#if @@ready.nil?
		#	raise "Chawk has not been setup yet."
		#end

		Chawk::Models::Agent.destroy_all
		Chawk::Models::Relation.destroy_all
		Chawk::Models::Node.destroy_all
		Chawk::Models::Point.destroy_all
		Chawk::Models::Value.destroy_all
		#Chawk::Models::AgentTag.destroy_all
		#Chawk::Models::Tag.destroy_all
	end


	# @param database_url [String]
	# Startup routine for Chawk, requires a database URL in DataMapper's standard format.
	def self.setup(database_url)
		#@@ready = true
		#adapter = DataMapper.setup(:default, database_url)
		#DataMapper::Model.raise_on_save_failure = true
		#DataMapper.finalize
		nil
	end
end

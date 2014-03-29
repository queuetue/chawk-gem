require "chawk/version"
require 'quantizer'
require 'models'

# Chawk is a gem for storing and retrieving time seris data.
module Chawk

	def self.check_node_relations_security(rel, access)
		if (rel && (rel.read || rel.admin))
			case access
			when :read
				(rel.read or rel.admin)
			when :write
				(rel.write or rel.write)
			when :admin
				rel.admin
			when :full
				(rel.read && rel.write && rel.admin)
			end
		end
	end

	def self.check_node_public_security(node, access)
		case access
		when :read
			node.public_read == true
		when :write
			node.public_write == true
		end
	end

	def self.check_node_security(agent,node,access=:full)

		rel = node.relations.where(agent_id:agent.id).first

		return node if check_node_relations_security(rel,access) || check_node_public_security(node,access)

		raise SecurityError,"You do not have permission to access this node. #{agent} #{rel} #{access}"
	end

	def self.find_or_create_node(agent,key,access=:full)
		#TODO also accept regex-tested string
		raise(ArgumentError,"Key must be a string.") unless key.is_a?(String)

		node = Chawk::Models::Node.where(key:key).first
		if node
			node = check_node_security(agent,node,access)
		else
			node = Chawk::Models::Node.create(key:key) if node.nil?
			node.set_permissions(agent,true,true,true)
		end
		node.access = access
		return node
	end

	# @param agent [Chawk::Agent] the agent whose permission will be used for this request 
	# @param key [String] the string address this node can be found in the database.
	# @return [Chawk::Node]
	# The primary method for retrieving an Node.  If a key does not exist, it will be created 
	# and the current agent will be set as an admin for it.
	def self.node(agent,key,access=:full)

		unless key =~ /^[\w\:\$\!\@\*\[\]\~\(\)]+$/
			raise ArgumentError, "Key can only contain [A-Za-z0-9_:$!@*[]~()] (#{key})"
		end

		unless agent.is_a?(Chawk::Models::Agent) 
			raise ArgumentError, 'Agent must be a Chawk::Models::Agent instance'
		end

		unless key.is_a?(String)
			raise ArgumentError, 'key must be a string.'
		end

		node = find_or_create_node(agent,key,access)

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
			dnode = node(agent,key)
			dnode.add_points dset
		end
	end


	# Deletes all data in the database.  Very dangerous.  Backup often!
	def self.clear_all_data!
		Chawk::Models::Agent.destroy_all
		Chawk::Models::Relation.destroy_all
		Chawk::Models::Node.destroy_all
		Chawk::Models::Point.destroy_all
		Chawk::Models::Value.destroy_all
	end
end

require "chawk/version"
require 'data_mapper'
require 'dm-is-tree'
require 'quantizer'
require 'models'
require 'addr'

# Chawk is a gem for storing and retrieving time seris data.
module Chawk

	# Has Chawk been setup yet?
	@@ready = nil

	# @param agent [Chawk::Agent] the agent whose permission will be used for this request 
	# @param path [String] the string address this addr can be found in the database.
	# @return [Chawk::Addr]
	# The primary method for retrieving an Addr.  If a path does not exist, it will be created 
	# and the current agent will be set as an admin for it.
	def self.addr(agent,path)
		if @@ready.nil?
			raise "Chawk has not been setup yet."
		end

		unless agent.is_a?(Chawk::Models::Agent) 
			raise ArgumentError, 'Agent must be a Chawk::Models::Agent instance'
		end

		unless path.is_a?(String)
			raise ArgumentError, 'Path must be a string.'
		end

		return Chawk::Addr.new(agent,path)

	end

	# Deletes all data in the database.  Very dangerous.  Backup often!
	def self.clear_all_data!
		if @@ready.nil?
			raise "Chawk has not been setup yet."
		end

		Chawk::Models::Agent.all.destroy!
		Chawk::Models::Relation.all.destroy!
		Chawk::Models::AgentTag.all.destroy!
		Chawk::Models::Tag.all.destroy!
		Chawk::Models::Node.all.destroy!
		Chawk::Models::Point.all.destroy!
		Chawk::Models::Value.all.destroy!
	end


	# @param database_url [String]
	# Startup routine for Chawk, requires a database URL in DataMapper's standard format.
	def self.setup(database_url)
		@@ready = true
		adapter = DataMapper.setup(:default, database_url)
		DataMapper::Model.raise_on_save_failure = true
		DataMapper.finalize
		nil
	end
end

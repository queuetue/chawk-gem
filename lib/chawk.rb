require "chawk/version"
require 'data_mapper'
require 'dm-is-tree'
require 'quantizer'
require 'board'


module Chawk

	@@ready = nil

	def self.addr(agent,path)
		if @@ready.nil?
			raise "Chawk has not been setup yet."
		end

		if agent.is_a?(Chawk::Models::Agent) && path.is_a?(String)
			return Chawk::Addr.new(agent,path)
		else
			raise ArgumentError
		end
	end

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


	def self.setup(database_url)
		@@ready = true
		adapter = DataMapper.setup(:default, database_url)
		DataMapper::Model.raise_on_save_failure = true
		DataMapper.finalize
		nil
	end
end

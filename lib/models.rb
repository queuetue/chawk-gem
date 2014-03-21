require 'active_record'
module Chawk
	# Models used in Chawk.  Most are DataMapper classes.
	module Models

		# Agent DataMapper classes.
		# Contains a foreign_id for use as a proxy to another table.
		class Agent < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			has_many :tags
			has_many :agent_tags
			has_many :relations
		end

		# Agent Relation DataMapper classes, with permission flags.
		class Relation < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			belongs_to :agent
			belongs_to :node
		end

		# Agent Tags.
		# Not implimented yet.
		# class AgentTag < ActiveRecord::Base
		# 	self.table_name_prefix = "chawk_"
		# 	belongs_to :agent
		# end

		# Item Tags.
		# Not implimented yet.
		# class Tag < ActiveRecord::Base
		# 	self.table_name_prefix = "chawk_"
		# end

		# The Node, where most Chawk:Addr information is persisted..
		class Node < ActiveRecord::Base
			attr_accessor :agent
			after_initialize :init
			self.table_name_prefix = "chawk_"
			belongs_to :agent
			has_many :points
			has_many :values
			has_many :relations			

			def init
				@agent = nil
			end

			def _insert_point(val,ts,options={})
				values = {value:val,observed_at:ts.to_f}
				values[:meta] = options[:meta] if options[:meta]
				self.points.create(values)
			end

			def point_recognizer(item, dt, options={})
				case 

				when item.is_a?(Integer)
					_insert_point item,dt, options
				when item.is_a?(Array)
					if item.length == 2 && item[0].is_a?(Integer) #value, timestamp
						_insert_point item[0],item[1], options
					else
						raise ArgumentError, "Array Items must be in [value,timestamp] format. #{item.inspect}"
					end
				when item.is_a?(Hash)
					if item['v'] && item['v'].is_a?(Integer)
						if item['t']
							_insert_point item['v'],item['t'], options
						else
							_insert_point item['v'],dt, options
						end
					else
						raise ArgumentError, "Hash must have 'v' key set to proper type.. #{item.inspect}"
					end
				else
					raise ArgumentError, "Can't recognize format of data item. #{item.inspect}"
				end
			end

			# @param args [Object, Array of Objects]
			# @param options [Hash] You can also pass in :meta and :timestamp 
			# Add an item or an array of items (one at a time) to the datastore.
			def add_points(args,options={})
				options[:observed_at] ? dt = options[:observed_at] : dt = Time.now
				if args.is_a?(Array)
					args.each do |arg|
						point_recognizer(arg, dt, options)
					end
				else
					point_recognizer(args, dt, options)
				end
			end

			def increment(value=1, options={})
				if value.is_a?(Integer)
					last = self.points.last
					add_points last.value + value,options 
				else 
					raise ArgumentError, "Value must be an Integer"
				end
			end

			def decrement(value=1, options={})
				if value.is_a?(Integer)
					increment (-1) * value, options
				else 
					raise ArgumentError, "Value must be an Integer"
				end
			end

			def max()
				points.maximum('value') || 0
			end

			def min()
				points.minimum('value') || 0
			end

			# Returns items whose observed_at times fit within from a range.
			# @param dt_from [Time::Time] The start time.
			# @param dt_to [Time::Time] The end time.
			# @return [Array of Objects] 
			def points_range(dt_from, dt_to,options={})
				vals = points.where("observed_at >= :dt_from AND  observed_at <= :dt_to",{dt_from:dt_from.to_f,dt_to:dt_to.to_f}, limit:1000,order:"observed_at asc, id asc")
				return vals
			end

			# Returns items whose observed_at times fit within from a range ending now.
			# @param dt_from [Time::Time] The start time.
			# @return [Array of Objects] 
			def points_since(dt_from)
				self.points_range(dt_from,Time.now)
			end

			# Sets public read flag for this address 
			# @param value [Boolean] true if public reading is allowed, false if it is not.
			def set_public_read(value)
				value = value ? true : false
				#DataMapper.logger.debug "MAKING #{@node.address} PUBLIC (#{value})"
				self.public_read = value
				save
			end

			# Sets permissions flag for this address, for a specific agent.  The existing Chawk::Relationship will be destroyed and 
			# a new one created as specified.  Write access is not yet checked.
			# @param agent [Chawk::Agent] the agent to give permission.
			# @param read [Boolean] true/false can the agent read this address.
			# @param write [Boolean] true/false can the agent write this address. (Read acces is required to write.)
			# @param admin [Boolean] does the agent have ownership/adnim rights for this address. (Read and write are granted if admin is as well.)
			def set_permissions(agent,read=false,write=false,admin=false)
				relations.where(agent:agent).destroy_all
				if read || write || admin
					vals = {agent:agent,read:(read ? true : false),write:(write ? true : false),admin:(admin ? true : false)}
					relations.create(vals)
				end
				nil
			end

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
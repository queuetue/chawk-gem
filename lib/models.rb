require 'active_record'
module Chawk
	# Models used in Chawk.  ActiveRecord classes.
	module Models

		class Range < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			validates :start_ts, :stop_ts, :beats, :parent_node, presence:true
			validates :subkey, :data_node, absence: true
			validate :order_is_correct

			before_create :build_subnode

			after_create :build_dataset

			belongs_to :parent_node, class_name:"Chawk::Models::Node"
			belongs_to :data_node, class_name:"Chawk::Models::Node"

			def build_subnode
				if subkey.to_s == ''
					self.subkey = parent_node.key + "/" + SecureRandom.hex.to_s
				end
				self.data_node = Chawk::Models::Node.create(key:subkey)
			end

			def order_is_correct
				if start_ts >= stop_ts
					errors.add(:stop_ts, "must be after start_ts.")
				end
			end

			def build_dataset
				populate!
			end

			def point_from_parent_point(now)
				point = parent_node.points.where("observed_at <= :dt_to",{dt_to:now}).order(observed_at: :desc, id: :desc).first
				if point
					value = point.value
				else
					value = default || 0
				end
				data_node.points.create(observed_at:now, recorded_at:Time.now, value:value)
			end

			def populate!
				# TODO: Accounting hook
				# TODO: perform in callback (celluloid?)
				self.data_node.points.destroy_all
				step = 0.25 * self.beats
				now = (self.start_ts*4).round/4.to_f
				while now < self.stop_ts
					point = point_from_parent_point now
					now += step
				end
			end
		end

		# Contains a foreign_id for use as a proxy to another table.
		class Agent < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			has_many :tags
			has_many :agent_tags
			has_many :relations
		end

		# Agent Relation classes, with permission flags.
		class Relation < ActiveRecord::Base
			self.table_name_prefix = "chawk_"
			belongs_to :agent
			belongs_to :node
		end

		# The Node, where most Chawk:Addr information is persisted..
		class Node < ActiveRecord::Base
			attr_accessor :agent
			after_initialize :init
			self.table_name_prefix = "chawk_"
			belongs_to :agent
			has_many :points
			has_many :values
			has_many :relations
			has_many :ranges, foreign_key: :parent_node_id

			def init
				@agent = nil
			end

			def invalidate!(at_list)
				ranges = []
				at_list.each do |at|
					self.ranges.where("start_ts <= ? AND stop_ts >= ?",at,at).each do |range|
						ranges << range
					end
				end

				ranges.uniq.each do |range|
					range.populate!
				end

			end

			def _insert_point(val,ts,options={})
				values = {value:val,observed_at:ts.to_f}
				if options[:meta]
					if options[:meta].is_a?(Hash)
						values[:meta] = options[:meta].to_json
					else
						raise ArgumentError, "Meta must be a JSON-representable Hash. #{options[:meta].inspect}"
					end
				end
				self.points.create(values)
				ts
			end

			def _insert_point_hash(item,ts,options)
				if item['v'] && item['v'].is_a?(Integer)
					if item['t']
						_insert_point item['v'],item['t'], options
					else
						_insert_point item['v'],ts, options
					end
				else
					raise ArgumentError, "Hash must have 'v' key set to proper type.. #{item.inspect}"
				end
			end

			def _insert_point_array(item,options)
				if item.length == 2 && item[0].is_a?(Integer)
					_insert_point item[0],item[1], options
				else
					raise ArgumentError, "Array Items must be in [value,timestamp] format. #{item.inspect}"
				end
			end

			def _insert_point_string(item,ts,options)
				if item.length > 0 && item =~ /\A[-+]?[0-9]+/
					_insert_point item.to_i,ts, options
				else
					raise ArgumentError, "String Items must represent Integer. #{item.inspect}"
				end
			end

			def point_recognizer(item, dt, options={})
				case 
				when item.is_a?(Integer)
					_insert_point item,dt, options
				when item.is_a?(Array)
					_insert_point_array(item, options)
				when item.is_a?(Hash)
					_insert_point_hash(item,dt,options)
				when item.is_a?(String)
					_insert_point_string(item,dt,options)
				else
					raise ArgumentError, "Can't recognize format of data item. #{item.inspect}"
				end
			end

			# @param args [Object, Array of Objects]
			# @param options [Hash] You can also pass in :meta and :timestamp 
			# Add an item or an array of items (one at a time) to the datastore.
			def add_points(args,options={})
				invalid_times = []
				options[:observed_at] ? dt = options[:observed_at] : dt = Time.now
				if args.is_a?(Array)
					args.each do |arg|
						invalid_times << point_recognizer(arg, dt, options)
					end
				else
						invalid_times << point_recognizer(args, dt, options)
				end
				invalidate! invalid_times.uniq
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

			def mean
				points = self.points.to_a
				points.reduce(0) {|sum,p| sum+=p.value}.to_f / points.length
			end

			def sum
				points = self.points.to_a
				points.reduce(0) {|sum,p| sum+=p.value}
			end

			def stdev
				dataset = self.points.map!(&:value)
				count = dataset.size
				mean = dataset.reduce(&:+) / count
				sum_sqr = dataset.map {|x| x * x}.reduce(&:+)
				Math.sqrt((sum_sqr - count * mean * mean)/(count-1))
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
				relations.where(agent_id:agent.id).destroy_all
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
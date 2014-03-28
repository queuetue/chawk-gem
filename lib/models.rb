require 'active_record'
require 'node'
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
				if self.start_ts >= self.stop_ts
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

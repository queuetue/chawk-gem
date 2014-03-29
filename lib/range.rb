require 'active_record'
module Chawk
  module Models
    class Range < ActiveRecord::Base
      self.table_name_prefix = "chawk_"
      validates :start_ts, :stop_ts, :beats, :parent_node, presence:true
      validates :subkey, :data_node, absence: true
      validate :order_is_correct

      before_create :build_subnode

      after_create :build_dataset
      after_find :grant_node_access

      belongs_to :parent_node, class_name:"Chawk::Models::Node"
      belongs_to :data_node, class_name:"Chawk::Models::Node"

      def reload
        super
        grant_node_access
      end

      def grant_node_access
        # TODO: vet this very carefully.
        # The only way to get here should be through an authorized source.
        self.data_node.access=:full
      end

      def build_subnode
        if subkey.to_s == ''
          self.subkey = parent_node.key + "/" + SecureRandom.hex.to_s
        end
        self.data_node = Chawk::Models::Node.create(key:subkey)
        grant_node_access
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
  end
end
require 'active_record'
module Chawk
  # Models used in Chawk.  ActiveRecord classes.
  module Models
    class NodeInvalidator
      extend Forwardable
      def_delegators :sweeps, :size, :map

      def initialize(node)
        @node = node
        @sweeps = []
        @selections = []
      end

      def <<(time)
        @node.selections.where('start_ts <= ? AND stop_ts >= ?', time, time).each do |selection|
          @selections << selection.id unless @selections.include?(selection.id)
        end
      end

      def invalidate!
        @selections.each { |r|Selection.find(r).populate! }
      end
    end

    # The Node, where most Chawk:Node information is persisted..
    class Node < ActiveRecord::Base
      attr_accessor :agent
      after_initialize :init
      self.table_name_prefix = 'chawk_'
      belongs_to :agent
      has_many :points
      has_many :values
      has_many :relations
      has_many :selections, foreign_key: :parent_node_id

      attr_accessor :access

      def init
        @agent = nil
      end

      def clear_values!
        check_admin_access
        values.destroy_all
      end

      def clear_points!
        check_admin_access
        points.destroy_all
      end

      def _prepare_insert(val, ts, options)
        values = { value: val, observed_at: ts.to_f }
        if options[:meta]
          if options[:meta].is_a?(Hash)
            values[:meta] = options[:meta].to_json
          else
            fail ArgumentError, "Meta must be a JSON-representable Hash. #{options[:meta].inspect}"
          end
        end
        values
      end

      def _insert_value(val, ts, options = {})
        values.create(_prepare_insert(val, ts, options))
        ts
      end

      def value_recognizer(item, dt, options = {})
        case
        when item.is_a?(String)
          _insert_value item, dt, options
        else
          fail ArgumentError, "Can't recognize format of data item. #{item.inspect}"
        end
      end

      def _unravel(items)
        if items.is_a?(Array)
          items.each do |item|
            yield item
          end
        else
          yield items
        end
      end

      def _add(args, type, options = {})
        check_write_access
        ni = NodeInvalidator.new(self)
        options[:observed_at] ? dt = options[:observed_at] : dt = Time.now
        _unravel(args) do |arg|
          case type
          when :point
            ni << point_recognizer(arg, dt, options)
          when :value
            ni << value_recognizer(arg, dt, options)
          end
        end
        ni.invalidate!
      end

      # @param args [Object, Array of Objects]
      # @param options [Hash] You can also pass in :meta and :timestamp
      # Add an item or an array of items (one at a time) to the datastore.
      def add_values(args, options = {})
        _add(args, :value, options)
      end

      # @param args [Object, Array of Objects]
      # @param options [Hash] You can also pass in :meta and :timestamp
      # Add an item or an array of items (one at a time) to the datastore.
      def add_points(args, options = {})
        _add(args, :point, options)
      end

      def _insert_point(val, ts, options = {})
        points.create(_prepare_insert(val, ts, options))
        ts
      end

      def _insert_point_hash(item, ts, options)
        if item['v'] && item['v'].is_a?(Integer)
          if item['t']
            _insert_point item['v'], item['t'], options
          else
            _insert_point item['v'], ts, options
          end
        else
          fail ArgumentError, "Hash must have 'v' key set to proper type.. #{item.inspect}"
        end
      end

      def _insert_point_array(item, options)
        if item.length == 2 && item[0].is_a?(Integer)
          _insert_point item[0], item[1], options
        else
          fail ArgumentError, "Array Items must be in [value,timestamp] format. #{item.inspect}"
        end
      end

      def _insert_point_string(item, ts, options)
        if item.length > 0 && item =~ /\A[-+]?[0-9]+/
          _insert_point item.to_i, ts, options
        else
          fail ArgumentError, "String Items must represent Integer. #{item.inspect}"
        end
      end

      def point_recognizer(item, dt, options = {})
        case
        when item.is_a?(Integer)
          _insert_point item, dt, options
        when item.is_a?(Array)
          _insert_point_array(item, options)
        when item.is_a?(Hash)
          _insert_point_hash(item, dt, options)
        when item.is_a?(String)
          _insert_point_string(item, dt, options)
        else
          fail ArgumentError, "Can't recognize format of data item. #{item.inspect}"
        end
      end

      def check_write_access
        unless [:full, :admin, :write].include? @access
          fail SecurityError, 'You do not have write access to this node.'
        end
      end

      def check_read_access
        unless [:full, :admin, :read].include? @access
          fail SecurityError, 'You do not have read access to this node.'
        end
      end

      def check_admin_access
        unless [:full, :admin, :read].include? @access
          fail SecurityError, 'You do not have admin access to this node.'
        end
      end

      def increment(value = 1, options = {})
        check_write_access
        if value.is_a?(Integer)
          last = points.last
          add_points last.value + value, options
        else
          fail ArgumentError, 'Value must be an Integer'
        end
      end

      def decrement(value = 1, options = {})
        check_write_access
        if value.is_a?(Integer)
          increment((-1 * value), options)
        else
          fail ArgumentError, 'Value must be an Integer'
        end
      end

      def _range(dt_from, dt_to, coll, options = {})
        check_read_access
        coll.where(
          'observed_at >= :dt_from AND  observed_at <= :dt_to',
          { dt_from: dt_from.to_f, dt_to: dt_to.to_f },
          limit: 1000, order: 'observed_at asc, id asc')
      end

      # Returns items whose observed_at times fit within from a range.
      # @param dt_from [Time::Time] The start time.
      # @param dt_to [Time::Time] The end time.
      # @return [Array of Objects]
      def values_range(dt_from, dt_to, options = {})
        _range(dt_from, dt_to, values, options)
      end

      # Returns items whose observed_at times fit within from a range ending now.
      # @param dt_from [Time::Time] The start time.
      # @return [Array of Objects]
      def values_since(dt_from)
        values_range(dt_from, Time.now)
      end

      # Returns items whose observed_at times fit within from a range.
      # @param dt_from [Time::Time] The start time.
      # @param dt_to [Time::Time] The end time.
      # @return [Array of Objects]
      def points_range(dt_from, dt_to, options = {})
        _range(dt_from, dt_to, points, options)
      end

      # Returns items whose observed_at times fit within from a range ending now.
      # @param dt_from [Time::Time] The start time.
      # @return [Array of Objects]
      def points_since(dt_from)
        points_range(dt_from, Time.now)
      end

      # Sets public read flag for this address
      # @param value [Boolean] true if public reading is allowed, false if it is not.
      def set_public_read(value)
        value = value ? true : false
        update_attributes public_read: value
        # save
      end

      # Sets public write flag for this address
      # @param value [Boolean] true if public writing is allowed, false if it is not.
      def set_public_write(value)
        value = value ? true : false
        update_attributes public_write: value
        # save
      end

      # Sets permissions flag for this address, for a specific agent.  The existing Chawk::Relationship will
      #  be destroyed and
      # a new one created as specified.  Write access is not yet checked.
      # @param agent [Chawk::Agent] the agent to give permission.
      # @param read [Boolean] true/false can the agent read this address.
      # @param write [Boolean] true/false can the agent write this address. (Read acces is required to write.)
      # @param admin [Boolean] does the agent have ownership/adnim rights for this address. (Read and write
      #   are granted if admin is as well.)
      def set_permissions(agent, read = false, write = false, admin = false)
        relations.where(agent_id: agent.id).delete_all
        if read || write || admin
          vals = {
            agent: agent,
            read: (read ? true : false),
            write: (write ? true : false),
            admin: (admin ? true : false)
          }
          relations.create(vals)
        end
        nil
      end
    end
  end
end

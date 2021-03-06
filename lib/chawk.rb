require 'chawk/version'
require 'quantizer'
require 'models'
require 'node'
require 'selection'
require 'aggregator'

# Chawk is a gem for storing and retrieving time seris data.
module Chawk

  include Chawk::Models
  def self.check_node_relations_security(rel, access)
    if rel && (rel.read || rel.admin)
      case access
      when :read
        (rel.read || rel.admin)
      when :write
        (rel.write || rel.write)
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

  def self.check_node_security(agent, node, access = :full)
    rel = node.relations.where(agent_id: agent.id).first

    return node if check_node_relations_security(rel, access) || check_node_public_security(node, access)

    fail SecurityError, "You do not have permission to access this node. #{agent} #{rel} #{access}"
  end

  def self.find_or_create_node(agent, key, access = :full)
    # TODO: also accept regex-tested string
    fail(ArgumentError, 'Key must be a string.') unless key.is_a?(String)

    node = Node.where(key: key).first
    if node
      node = check_node_security(agent, node, access)
    else
      node = Node.create(key: key) if node.nil?
      node.set_permissions(agent, true, true, true)
    end
    node.access = access
    node
  end

  # @param agent [Chawk::Agent] the agent whose permission will be used for this request
  # @param key [String] the string address this node can be found in the database.
  # @return [Chawk::Node]
  # The primary method for retrieving an Node.  If a key does not exist, it will be created
  # and the current agent will be set as an admin for it.
  def self.node(agent, key, access = :full)
    unless key =~ /^[\w\:\$\!\@\*\[\]\~\(\)]+$/
      fail ArgumentError, "Key can only contain [A-Za-z0-9_:$!@*[]~()] (#{key})"
    end

    fail ArgumentError, 'Agent must be a Agent instance' unless agent.is_a?(Agent)

    fail ArgumentError, 'key must be a string.' unless key.is_a?(String)

    node = find_or_create_node(agent, key, access)

    fail ArgumentError, 'No node was returned.'     unless node

    node.agent = agent
    node
  end

  # @param agent [Chawk::Agent] the agent whose permission will be used for this request
  # @param data [Hash] the bulk data to be inserted
  # Insert data for multiple addresses at once.  Format should be a hash of valid data sets keyed by address
  # example: {'key1'=>[1,2,3,4,5],'key2'=>[6,7,8,9]}
  def self.bulk_add_points(agent, data)
    data.keys.each do |key|
      dset = data[key]
      dnode = node(agent, key)
      dnode.add_points dset
    end
  end

  # Deletes all data in the database.  Very dangerous.  Backup often!
  def self.clear_all_data!
    Agent.destroy_all
    Relation.destroy_all
    Node.destroy_all
    Point.destroy_all
    Value.destroy_all
  end
end

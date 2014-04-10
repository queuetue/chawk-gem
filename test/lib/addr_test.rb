require 'test_helper'
require 'json'

include Chawk::Models

describe Chawk do
  before do
    Chawk.clear_all_data!
    @agent =  Agent.first || Agent.create(name: 'Test User')
    @node = Chawk.node(@agent, 'a:b')
  end

  it 'has a good agent' do
    -> { Chawk.node(nil, 'a:b') }.must_raise(ArgumentError)
    -> { Chawk.node(Object.new, 'a:b') }.must_raise(ArgumentError)
    -> { Chawk.node(Agent, 'a:b') }.must_raise(ArgumentError)
    Chawk.node(@agent, 'a:b').key.must_equal('a:b')
    agent2 =  Agent.first || Agent.create(name: 'Test User')
    Chawk.node(agent2, 'a:b').key.must_equal('a:b')
    agent3 =  Agent.create(name: 'Test Failer')
    -> { Chawk.node(agent3, 'a:b').key.must_equal('a:b') }.must_raise(
    SecurityError)
  end

  it 'has key' do
    @node.must_respond_to(:key)
  end

  it 'key is valid' do
    @node.key.must_equal('a:b')
    Chawk.node(@agent, 'a:b').key.must_equal('a:b')
    Chawk.node(@agent, '0:x:z').key.must_equal('0:x:z')
    path = 'ABCDEFYZabcdefyz012345689_:$!@*[]~()'
    Chawk.node(@agent, path).key.must_equal(path)
  end

  it 'rejects invalid paths' do
    -> { Chawk.node(@agent, ['A']) }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, 0) }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, :a) }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, Object.new) }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, String.new) }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, '') }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, '/') }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, '\\') }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, '&') }.must_raise(ArgumentError)
    -> { Chawk.node(@agent, '?') }.must_raise(ArgumentError)
  end

  it 'sets permissions' do
    @node.must_respond_to(:set_public_read)
    @node.must_respond_to(:set_permissions)
  end

  it 'stops unauthorized access' do
    @node.set_permissions(@agent, true, false, false)
    @node = Node.find(@node.id)
    -> { Chawk.node(@agent, 'a:b') }.must_raise SecurityError
    @node.set_permissions(@agent, false, false, false)
    -> { Chawk.node(@agent, 'a:b') }.must_raise SecurityError
  end

  it 'stops unauthorized reads' do
    @node.set_permissions(@agent, false, false, false)
    -> { Chawk.node(@agent, 'a:b', :write) }.must_raise SecurityError
    @node.set_public_read true
    Chawk.node(@agent, 'a:b', :read).key.must_equal 'a:b'
    @node.set_public_read false
    -> { Chawk.node(@agent, 'a:b', :read) }.must_raise SecurityError
    @node.set_permissions(@agent, true, true, false)
    w_node = Chawk.node(@agent, 'a:b', :write)
    -> { w_node.values_range(0, 0) }.must_raise SecurityError
  end

  it 'stops unauthorized writes' do
    @node.set_permissions(@agent, true, false, false)
    -> { Chawk.node(@agent, 'a:b', :write) }.must_raise SecurityError
    @node.set_public_write true
    Chawk.node(@agent, 'a:b', :write).key.must_equal 'a:b'
    @node.set_public_write false
    -> { Chawk.node(@agent, 'a:b', :write) }.must_raise SecurityError
    r_node = Chawk.node(@agent, 'a:b', :read)
    -> { r_node.add_points([1, 2, 3, 4]) }.must_raise SecurityError
  end

  it 'stops unauthorized admin' do
    @node.set_permissions(@agent, false, false, false)
    -> { Chawk.node(@agent, 'a:b', :admin) }.must_raise SecurityError
    @node.set_permissions(@agent, false, true, true)
    Chawk.node(@agent, 'a:b', :admin).key.must_equal 'a:b'
    w_node = Chawk.node(@agent, 'a:b', :write)
    -> { w_node.clear_points! }.must_raise SecurityError
  end

end

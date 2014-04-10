require 'test_helper'
require 'json'

describe Chawk do
  before do
    Chawk.clear_all_data!
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(name: 'Test User')
    @node = Chawk.node(@agent, 'a:b')
    @node.clear_values!
  end

  it 'has length' do
    @node.values.must_respond_to(:length)
  end

  it :calculates_length do
    @node.clear_values!
    @node.values.length.must_equal(0)
    @node.add_values '2'
    @node.values.length.must_equal(1)
    @node.add_values '2'
    @node.values.length.must_equal(2)
    @node.add_values 'FLEAS!'
    @node.values.length.must_equal(3)
    @node.add_values %w(CAT DOG COW CHIPMUNK)
    @node.values.length.must_equal(7)
  end

  it 'clears history' do
    @node.add_values ['CLAM', 'FISH', 'SEAHORSE', 'AQUAMAN', 'WET TIGER']
    @node.values.length.must_equal(5)
    @node.clear_values!
    @node.values.length.must_equal(0)
  end

  it 'accepts _insert_value' do
    @node._insert_value('SHOCK THE MONKEY', Time.now)
    @node.values.length.must_equal(1)
  end

  it 'accepts add_value' do
    @node.must_respond_to(:"add_values")
  end

  it 'accepts strings' do
    @node.add_values 'A'
    @node.values.length.must_equal(1)
    @node.add_values 'B'
    @node.values.length.must_equal(2)
    @node.add_values 'C'
    @node.add_values 'DDDD'
    @node.add_values %w(MY DOG HAS FLEAS)
  end

  it 'only accepts strings' do
    -> { @node.add_values 10 }.must_raise(ArgumentError)
    -> { @node.add_values 10.0 }.must_raise(ArgumentError)
    -> { @node.add_values Object.new }.must_raise(ArgumentError)
    -> { @node.add_values nil }.must_raise(ArgumentError)
    -> { @node.add_values ['MY', :DOG, :HAS, :FLEAS] }.must_raise(ArgumentError)
  end

  it 'has last()' do
    @node.values.must_respond_to(:last)
  end

  it 'remembers last value' do
    @node.add_values 'ALL'
    @node.values.last.value.must_equal('ALL')
    @node.add_values 'GOOD'
    @node.values.last.value.must_equal('GOOD')
    @node.add_values 'BOYS'
    @node.values.last.value.must_equal('BOYS')
    @node.add_values %w(GO TO THE FAIR)
    @node.values.last.value.must_equal('FAIR')
  end

  it 'returns ordinal last' do
    @node.add_values(('a'..'z').to_a)
    @node.values.last(5).length.must_equal(5)
  end

  it :does_range do
    @node.must_respond_to(:values_range)

    ts = Time.now
    @node._insert_value('0', ts - 1000)
    @node._insert_value('1', ts - 1000)
    @node._insert_value('2', ts - 1000)
    @node._insert_value('3', ts - 1000)
    @node._insert_value('4', ts - 1000)
    @node._insert_value('5', ts - 800)
    @node._insert_value('6', ts - 800)
    @node._insert_value('7', ts - 800)
    @node._insert_value('8', ts - 200)
    @node._insert_value('9', ts - 10)
    @node._insert_value('10', ts - 5)
    @node.values_range(ts - 1001, ts).length.must_equal 11
    @node.values_range(ts - 801, ts).length.must_equal 6
    @node.values_range(ts - 201, ts).length.must_equal 3
    @node.values_range(ts - 11, ts).length.must_equal 2
    @node.values_range(ts - 6, ts).length.must_equal 1
    @node.values_range(ts - 201, ts - 11).length.must_equal 1
    @node.values_range(ts - 1001, ts - 990).length.must_equal 5

    @node._insert_value('0', ts - 100)
    @node.values_range(ts - 201, ts).length.must_equal 4
  end

  it 'does since' do
    ts = Time.now
    @node.must_respond_to(:values_since)
    @node._insert_value('0', ts - 1000)
    @node._insert_value('7', ts - 800)
    @node._insert_value('8', ts - 200)
    @node._insert_value('10', ts - 5)
    @node.values_since(ts - 1001).length.must_equal(4)
    @node.values_since(ts - 301).length.must_equal(2)
  end

  it 'handles serialized data' do
    serial = (1..100).map { |x|'X' * (100) }.to_json
    @node.add_values(serial)
    last = @node.values.last
    ary = JSON.parse(last.value.to_s)
    ary.length.must_equal 100
    ary[-1].must_equal('X' * 100)
  end

end

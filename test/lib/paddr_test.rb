require 'test_helper'

describe Chawk do
  before do
    Chawk.clear_all_data!
    @agent =  Agent.first || Agent.create(name: 'Test User')
    @node = Chawk.node(@agent, 'a:b')
  end

  it 'has length' do
    @node.points.must_respond_to(:length)
  end

  it 'calculates length' do
    @node.clear_points!
    @node.points.length.must_equal(0)
    @node.add_points 2
    @node.points.length.must_equal(1)
    @node.add_points 2
    @node.points.length.must_equal(2)
    @node.add_points 2
    @node.points.length.must_equal(3)
    @node.add_points [1, 2, 3, 4]
    @node.points.length.must_equal(7)
  end

  it 'clears points' do
    @node.must_respond_to(:clear_points!)
  end

  it 'clears history' do
    @node.add_points [1, 2, 3, 4]
    @node.points.length.must_equal(4)
    @node.clear_points!
    @node.points.length.must_equal(0)
  end

  it "doesn't clear the wrong history" do
    node2 = Chawk.node(@agent, 'a:b')
    node2.clear_points!
    @node.clear_points!
    node2.add_points [1, 2, 3, 4]
    @node.add_points [1, 2, 3, 4]
    node2.clear_points!
    node2.points.length.must_equal(0)
    @node.points.length.must_equal(4)
  end

  it 'accepts _insert_point' do
    @node._insert_point(100, Time.now)
    @node.points.length.must_equal(1)
  end

  it 'accepts add_points' do
    @node.must_respond_to(:"add_points")
  end

  it 'accepts integers' do
    @node.add_points 10
    @node.points.length.must_equal(1)
    @node.add_points 0
    @node.points.length.must_equal(2)
    @node.add_points 190
    @node.add_points 10_002
    @node.add_points [10, 0, 190, 100]
    dt = Time.now.to_f
    @node.add_points [[10, dt], [0, dt], [190, dt], [100, dt]]
    @node.add_points [{ 'v' => 10 }, { 'v' => 0 }, { 'v' => 190 }, { 'v' => 100, 't' => dt }]
    @node.add_points [
      { 'v' => 10, 't' => dt }, { 'v' => 0, 't' => dt },
      { 'v' => 190, 't' => dt }, { 'v' => 100, 't' => dt }
    ]
    @node.add_points [
      { 't' => dt, 'v' => 10 }, { 'v' => 0, 't' => dt },
      { 't' => dt, 'v' => 190 }, { 'v' => 100, 't' => dt }
    ]
  end

  it 'does increment' do
    @node.clear_points!
    @node.add_points 99
    @node.must_respond_to(:increment)
    @node.increment 10
    @node.increment
    @node.points.last.value.must_equal(110)
    @node.increment(-10)
    @node.points.last.value.must_equal(100)
    @node.increment
    @node.points.last.value.must_equal(101)
  end

  it 'should only increment integers' do
    -> { @node.increment 'A' }.must_raise(ArgumentError)
    -> { @node.increment nil }.must_raise(ArgumentError)
  end

  it 'does -' do
    @node.points.must_respond_to(:"-")
    @node.add_points 10
    @node.decrement 100
    @node.points.last.value.must_equal(-90)
    @node.decrement(-10)
    @node.points.last.value.must_equal(-80)
    @node.decrement
    @node.points.last.value.must_equal(-81)
  end

  it 'should only - integers' do
    -> { @node.decrement 'A' }.must_raise(ArgumentError)
    -> { @node.decrement nil }.must_raise(ArgumentError)
  end

  it 'only accepts integers in proper formats' do
    -> { @node.add_points 10.0 }.must_raise(ArgumentError)
    -> { @node.add_points nil }.must_raise(ArgumentError)
    -> { @node.add_points [10.0, :x] }.must_raise(ArgumentError)
    -> { @node.add_points [[10, 10, 10], [10, 10, 20]] }.must_raise(ArgumentError)
    dt = Time.now.to_f
    -> { @node.add_points [{ 'x' => 10, 't' => dt }, { 'x' => 0, 't' => dt }] }.must_raise(ArgumentError)
  end

  it 'accepts string integers in proper formats' do
    -> { @node.add_points 'X' }.must_raise(ArgumentError)
    @node.add_points '10'
    @node.points.length.must_equal(1)
    @node.add_points '0'
    @node.points.length.must_equal(2)
    @node.add_points '190'
    @node.add_points '10002'
    @node.add_points %w(10 0 190 100)
    @node.points.length.must_equal(8)
  end

  it 'does bulk add points' do
    dt = Time.now.to_f
    Chawk.bulk_add_points(
      @agent,
      'xxx' => [1, 2, 3, 4, 5, 6],
      'yyy' => [[10, dt], [10, dt]],
      'zzz' => [{ 't' => dt, 'v' => 10 }, { 'v' => 0, 't' => dt }]
      )

    Chawk.node(@agent, 'xxx').points.length.must_equal 6
    Chawk.node(@agent, 'zzz').points.length.must_equal 2
    Chawk.node(@agent, 'zzz').points.last.value.must_equal 0

  end

  it 'has last()' do
    @node.points.must_respond_to(:last)
  end

  it 'remembers last value' do
    @node.add_points 10
    @node.points.last.value.must_equal(10)
    @node.add_points 1000
    @node.points.last.value.must_equal(1000)
    @node.add_points 99
    @node.points.last.value.must_equal(99)
    @node.add_points [10, 0, 190, 100]
    @node.points.last.value.must_equal(100)
  end

  it 'stores meta information' do

    metadata = { 'info' => 'this is a test' }
    @node.add_points([1, 2, 3, 4], meta: metadata)
    @node.points.last.value.must_equal(4)
    meta = @node.points.last.meta
    JSON.parse(meta).must_equal(metadata)

    metadata = { 'number' => 123 }
    @node.add_points([1, 2, 3, 4], meta: metadata)
    @node.points.last.value.must_equal(4)
    JSON.parse(@node.points.last.meta).must_equal(metadata)

    metadata = ['completely wrong']
    -> { @node.add_points([1, 2, 3, 4], meta: metadata) }.must_raise(ArgumentError)

  end

  it 'returns ordinal last' do
    @node.add_points [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    @node.points.last(5).length.must_equal(5)
  end

   # it "has max()" do
  #     @node.must_respond_to(:max)
   # end

   # it "does max()" do
   #   @node.clear_points!
   #   @node.add_points [1,2,3,4,5]
   #   @node.max.must_equal(5)
   #   @node.add_points 100
   #   @node.max.must_equal(100)
   #   @node.add_points 100
   #   @node.max.must_equal(100)
   #   @node.add_points 99
   #   @node.max.must_equal(100)
   #   @node.add_points 0
   #   @node.max.must_equal(100)
   # end

   # it "does min()" do
   #   @node.add_points [11,12,13,14,15]
   #   @node.min.must_equal(11)
   #   @node.add_points 100
   #   @node.min.must_equal(11)
   #   @node.add_points 10
   #   @node.min.must_equal(10)
   #   @node.add_points 99
   #   @node.min.must_equal(10)
   #   @node.add_points 0
   #   @node.min.must_equal(0)
   # end

  it :does_range do
    @node.must_respond_to(:points_range)

    ts = Time.now

    @node._insert_point(0, ts - 1000)
    @node._insert_point(1, ts - 1000)
    @node._insert_point(2, ts - 1000)
    @node._insert_point(3, ts - 1000)
    @node._insert_point(4, ts - 1000)
    @node._insert_point(5, ts - 800)
    @node._insert_point(6, ts - 800)
    @node._insert_point(7, ts - 800)
    @node._insert_point(8, ts - 200)
    @node._insert_point(9, ts - 10)
    @node._insert_point(10, ts - 5)
    @node.points_range(ts - 1001, ts).length.must_equal 11
    @node.points_range(ts - 801, ts).length.must_equal 6
    @node.points_range(ts - 201, ts).length.must_equal 3
    @node.points_range(ts - 11, ts).length.must_equal 2
    @node.points_range(ts - 6, ts).length.must_equal 1
    @node.points_range(ts - 201, ts - 11).length.must_equal 1
    @node.points_range(ts - 1001, ts - 999).length.must_equal 5

    @node._insert_point(0, ts - 101)
    @node.points_range(ts - 201, ts).length.must_equal 4
  end

  it 'does since' do
    @node.clear_points!
    ts = Time.now
    @node._insert_point(0, ts - 1000)
    @node._insert_point(7, ts - 800)
    @node._insert_point(8, ts - 200)
    @node._insert_point(10, ts - 5)
    @node.must_respond_to(:points_since)
    @node.points_since(ts - 1001).length.must_equal(4)
    @node.points_since(ts - 301).length.must_equal(2)
  end

end

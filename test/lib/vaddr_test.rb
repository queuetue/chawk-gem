 require 'test_helper'
 require 'json'

describe Chawk::Vaddr do
 	before do
		@board = Chawk::Board.new()
		@agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
		@addr = @board.addr(@agent,'a/b')
	   	@addr.values.clear_history!
 	end

 	it "has length" do
  		@addr.values.must_respond_to(:length)
 	end

	it :calculates_length do
		@addr.values.clear_history!
		@addr.values.length.must_equal(0)
		@addr.values << "2"
		@addr.values.length.must_equal(1)
		@addr.values << "2"
		@addr.values.length.must_equal(2)
		@addr.values << "FLEAS!"
		@addr.values.length.must_equal(3)
		@addr.values << ["CAT","DOG","COW","CHIPMUNK"]
		@addr.values.length.must_equal(7)
	end

	it "has clear_history!" do
		@addr.values.must_respond_to(:clear_history!)
	end

	it "clears history" do
		@addr.values.clear_history!
		@addr.values.length.must_equal(0)
	end

	it :accepts__insert do
		@addr.values._insert("SHOCK THE MONKEY",Time.now)
		@addr.values.length.must_equal(1)
	end

	it "accepts <<" do
		@addr.values.must_respond_to(:"<<")
	end

	it "accepts strings" do
		@addr.values << "A"
		@addr.values.length.must_equal(1)
		@addr.values << "B"
		@addr.values.length.must_equal(2)
		@addr.values << "C"
		@addr.values << "DDDD"
		@addr.values << ["MY","DOG","HAS","FLEAS"]
	end

	it "only accepts strings" do
		lambda {@addr.values << 10}.must_raise(ArgumentError)
		lambda {@addr.values << 10.0}.must_raise(ArgumentError)
		lambda {@addr.values << Object.new}.must_raise(ArgumentError)
		lambda {@addr.values << nil}.must_raise(ArgumentError)
		lambda {@addr.values << ["MY",:DOG,:HAS,:FLEAS]}.must_raise(ArgumentError)
	end

	it "has last()" do
		@addr.values.must_respond_to(:last)
	end

	it "remembers last value" do
		@addr.values << "ALL"
		@addr.values.last.value.must_equal("ALL")
		@addr.values << "GOOD"
		@addr.values.last.value.must_equal("GOOD")
		@addr.values << "BOYS"
		@addr.values.last.value.must_equal("BOYS")
		@addr.values << ["GO","TO","THE","FAIR"]
		@addr.values.last.value.must_equal("FAIR")
	end

	it "returns ordinal last" do
		@addr.values << ("a".."z").to_a
		@addr.values.last(5).length.must_equal(5)
	end

	it :does_range do
	@addr.values.must_respond_to(:range)

	ts = Time.now
		@addr.values._insert('0',ts-1000)
		@addr.values._insert('1',ts-1000)
		@addr.values._insert('2',ts-1000)
		@addr.values._insert('3',ts-1000)
		@addr.values._insert('4',ts-1000)
		@addr.values._insert('5',ts-800)
		@addr.values._insert('6',ts-800)
		@addr.values._insert('7',ts-800)
		@addr.values._insert('8',ts-200)
		@addr.values._insert('9',ts-10)
		@addr.values._insert('10',ts-5)
		@addr.values.range(ts-1000,ts).length.must_equal 11 
		@addr.values.range(ts-800,ts).length.must_equal 6 
		@addr.values.range(ts-200,ts).length.must_equal 3 
		@addr.values.range(ts-10,ts).length.must_equal 2 
		@addr.values.range(ts-5,ts).length.must_equal 1 
		@addr.values.range(ts-200,ts-11).length.must_equal 1 
		@addr.values.range(ts-1000,ts-1000).length.must_equal 5

		@addr.values._insert('0',ts-100)
		@addr.values.range(ts-200,ts).length.must_equal 4 
	end

	it "does since" do
		ts = Time.now
		@addr.values._insert('0',ts-1000)
		@addr.values._insert('7',ts-800)
		@addr.values._insert('8',ts-200)
		@addr.values._insert("10",ts-5)
		@addr.values.must_respond_to(:since)
		@addr.values.since(ts-1000).length.must_equal(4) 
		@addr.values.since(ts-300).length.must_equal(2) 
	end

	it "handles serialized data" do
		serial = (1..100).collect{|x|"X" * (100)}.to_json
		@addr.values.<< serial
		last = @addr.values.last
		ary = JSON.parse(last.value.to_s)
		ary.length.must_equal 100
		ary[-1].must_equal ("X" * 100)
	end

	# it :acts_like_a_string do
	# 	@addr.values << "GET DOWN!"
	# 	last = @addr.values.last
	# 	last.to_s.must_equal ("GET DOWN!")
	# end


	# it "does mq" do
	# 	@board.flush_notification_queue
	# 	@board.notification_queue_length.must_equal (0)

	# 	pointers = []
	#    	pointers << @board.addr(['0','1','2'])
	#    	pointers << @board.addr(['0','1','3'])
	#    	pointers << @board.addr(['0','1','4'])
	#    	pointers << @board.addr(['0','1','5'])

	#    	pointers.each{|p|p<<10}

	# 	@board.notification_queue_length.must_equal (4)
	# 	x = @board.pop_from_notification_queue
	# 	x.length.must_equal(3)
	# 	@board.notification_queue_length.must_equal (3)
	# 	x = @board.pop_from_notification_queue
	# 	x = @board.pop_from_notification_queue
	# 	@board.notification_queue_length.must_equal (1)
	# 	x.length.must_equal(3)
	# end
end
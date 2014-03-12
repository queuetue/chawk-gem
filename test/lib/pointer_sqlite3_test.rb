require 'test_helper'

describe Chawk::SqliteChawkboard do
	#it "prevents database mismatch" do
	#	Chawk::SqliteChawkboard.new(":memory:")
	#	Chawk::SqliteChawkboard.new(":memory:",{IGNORE_DB_PROTOCOL:true}).set_db_version "testing-XX"
	#	lambda {Chawk::SqliteChawkboard.new(":memory:")}.must_raise(RuntimeError)
	#end
end

describe Chawk::SqlitePointer do
	before do
		@board = Chawk::Board.new() #SqliteChawkboard.new(":memory:")
    	@pointer = @board.get_pointer(['a','b'])
	end

    it "has version()" do
 		@pointer.must_respond_to(:version)
    end

	it "has address()" do
 		@pointer.must_respond_to(:address)
	end

	it "address is a/b" do
 		@pointer.address.must_equal("a/b")
	   	@board.get_pointer(['0','x','z']).address.must_equal("0/x/z")
 	end

 	it "rejects invalid paths" do
		lambda {@board.get_pointer('A')}.must_raise(ArgumentError)
		lambda {@board.get_pointer(0)}.must_raise(ArgumentError)
		lambda {@board.get_pointer(['/','x','z'])}.must_raise(ArgumentError)
		lambda {@board.get_pointer(['a/a','x','z'])}.must_raise(ArgumentError)
 	end

	it "accepts <<" do
		@pointer.must_respond_to(:"<<")
	end

	it "accepts integers" do
		@pointer.clear_history!
		@pointer << 10
		@pointer << 0
		@pointer << 190
		@pointer << 10000
		@pointer << [10,0,190,10000]
		@pointer.length.must_equal(8)
	end

	it "does +" do
		@pointer.must_respond_to(:"+")
		@pointer << 10
		@pointer + 100
		@pointer.last.value.must_equal(110)
		@pointer + -10
		@pointer.last.value.must_equal(100)
		@pointer.+ 
		@pointer.last.value.must_equal(101)
	end

	it "should only + integers" do
		lambda {@pointer + 'A'}.must_raise(ArgumentError)
		lambda {@pointer + nil}.must_raise(ArgumentError)
	end

	it "does -" do
		@pointer.must_respond_to(:"-")
		@pointer << 10
		@pointer - 100
		@pointer.last.value.must_equal(-90)
		@pointer - -10
		@pointer.last.value.must_equal(-80)
		@pointer.- 
		@pointer.last.value.must_equal(-81)
	end

	it "should only - integers" do
		lambda {@pointer - 'A'}.must_raise(ArgumentError)
		lambda {@pointer - nil}.must_raise(ArgumentError)
	end

	it "only accepts integers" do
		lambda {@pointer << 10.0}.must_raise(ArgumentError)
		lambda {@pointer << nil}.must_raise(ArgumentError)
	end

	it "has last()" do
 		@pointer.must_respond_to(:last)
	end

	it "remembers last value" do
		@pointer << 10
 		@pointer.last.value.must_equal(10)
		@pointer << 1000
 		@pointer.last.value.must_equal(1000)
		@pointer << 99
 		@pointer.last.value.must_equal(99)
		@pointer << [10,0,190,10000]
 		@pointer.last.value.must_equal(10000)
	end

	it "returns ordinal last" do
		@pointer << [10,9,8,7,6,5,4,3,2,1,0]
 		@pointer.last(5).length.must_equal(5)
	end


	it "has clear_history!()" do
 		@pointer.must_respond_to(:clear_history!)
	end

	it "has length()" do
 		@pointer.must_respond_to(:length)
	end

	it "clears history" do
		@pointer.clear_history!
		@pointer.length.must_equal(0)
	end

	it "calculates length" do
		@pointer.clear_history!
		@pointer.length.must_equal(0)
		@pointer << 2
		@pointer.length.must_equal(1)
		@pointer << 2
		@pointer.length.must_equal(2)
		@pointer << 2
		@pointer.length.must_equal(3)
		@pointer << [1,2,3,4]
		@pointer.length.must_equal(7)
	end

	it "has max()" do
 		@pointer.must_respond_to(:max)
	end

	it "does max()" do
		@pointer.clear_history!
		@pointer << [1,2,3,4,5]
		@pointer.max.value.must_equal(5)
		@pointer << 100
		@pointer.max.value.must_equal(100)
		@pointer << 100
		@pointer.max.value.must_equal(100)
		@pointer << 99
		@pointer.max.value.must_equal(100)
		@pointer << 0
		@pointer.max.value.must_equal(100)
	end

	it "does min()" do
		@pointer.clear_history!
		@pointer << [11,12,13,14,15]
		@pointer.min.value.must_equal(11)
		@pointer << 100
		@pointer.min.value.must_equal(11)
		@pointer << 10
		@pointer.min.value.must_equal(10)
		@pointer << 99
		@pointer.min.value.must_equal(10)
		@pointer << 0
		@pointer.min.value.must_equal(0)
	end

	it "does range" do
 		@pointer.must_respond_to(:range)

 		ts = Time.now

 		@pointer._insert(0,ts-1000)
 		@pointer._insert(1,ts-1000)
 		@pointer._insert(2,ts-1000)
 		@pointer._insert(3,ts-1000)
 		@pointer._insert(4,ts-1000)
 		@pointer._insert(5,ts-800)
 		@pointer._insert(6,ts-800)
 		@pointer._insert(7,ts-800)
 		@pointer._insert(8,ts-200)
 		@pointer._insert(9,ts-10)
 		@pointer._insert(10,ts-5)

	  	@pointer.range(ts-1000,ts).length.must_equal 11 
	  	@pointer.range(ts-800,ts).length.must_equal 6 
	  	@pointer.range(ts-200,ts).length.must_equal 3 
	  	@pointer.range(ts-10,ts).length.must_equal 2 
	  	@pointer.range(ts-5,ts).length.must_equal 1 
	  	@pointer.range(ts-200,ts-11).length.must_equal 1 
	  	@pointer.range(ts-1000,ts-1000).length.must_equal 5

 		@pointer._insert(0,ts-100)
	  	@pointer.range(ts-200,ts).length.must_equal 4 
	end

	it "does since" do
 		ts = Time.now

 		@pointer._insert(0,ts-1000)
 		@pointer._insert(7,ts-800)
 		@pointer._insert(8,ts-200)
 		@pointer._insert(10,ts-5)
 		@pointer.must_respond_to(:since)
	  	values = @pointer.since(ts-1000).length.must_equal(4) 
	  	values = @pointer.since(ts-300).length.must_equal(2) 
	end

	it "does mq" do
		@board.flush_notification_queue
		@board.notification_queue_length.must_equal (0)

		pointers = []
	   	pointers << @board.get_pointer(['0','1','2'])
	   	pointers << @board.get_pointer(['0','1','3'])
	   	pointers << @board.get_pointer(['0','1','4'])
	   	pointers << @board.get_pointer(['0','1','5'])

	   	pointers.each{|p|p<<10}

		@board.notification_queue_length.must_equal (4)
		x = @board.pop_from_notification_queue
		x.length.must_equal(3)
		@board.notification_queue_length.must_equal (3)
		x = @board.pop_from_notification_queue
		x = @board.pop_from_notification_queue
		@board.notification_queue_length.must_equal (1)
		x.length.must_equal(3)
	end
end
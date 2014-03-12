require 'test_helper'

describe Chawk::Vaddr do
 	before do
 		@board = Chawk::Board.new()
     	@vaddr = @board.values.addr(['a','b'])
     	@vaddr.clear_history!
 	end

 	it "has path" do
  		@vaddr.must_respond_to(:path)
 	end

 	it "has address" do
  		@vaddr.must_respond_to(:address)
 	end

 	it "address is a/b" do
  		@vaddr.address.must_equal("a/b")
 	   	@board.values.addr(['0','x','z']).address.must_equal("0/x/z")
  	end

  	it "rejects invalid paths" do
 		lambda {@board.values.addr('A')}.must_raise(ArgumentError)
 		lambda {@board.values.addr(0)}.must_raise(ArgumentError)
 		lambda {@board.values.addr(['/','x','z'])}.must_raise(ArgumentError)
 		lambda {@board.values.addr(['a/a','x','z'])}.must_raise(ArgumentError)
  	end

 	it "has length" do
  		@vaddr.must_respond_to(:length)
 	end

 	it "calculates length" do
 		@vaddr.clear_history!
 		@vaddr.length.must_equal(0)
 		@vaddr << 2
 		@vaddr.length.must_equal(1)
 		@vaddr << 2
 		@vaddr.length.must_equal(2)
 		@vaddr << 2
 		@vaddr.length.must_equal(3)
 		@vaddr << [1,2,3,4]
 		@vaddr.length.must_equal(7)
 	end

 	it "has clear_history!" do
  		@vaddr.must_respond_to(:clear_history!)
 	end

 	it "clears history" do
 		@vaddr.clear_history!
 		@vaddr.length.must_equal(0)
 	end

 	it "accepts _insert" do
 		@vaddr._insert(100,Time.now)
 		@vaddr.length.must_equal(1)
 	end

 	it "accepts <<" do
 		@vaddr.must_respond_to(:"<<")
 	end

 	it "accepts integers" do
 		@vaddr << 10
 		@vaddr.length.must_equal(1)
 		@vaddr << 0
 		@vaddr.length.must_equal(2)
 		@vaddr << 190
 		@vaddr << 10002
 		@vaddr << [10,0,190,100]
 	end

 	it "does +" do
 		@vaddr.must_respond_to(:"+")
 		@vaddr << 10
 		@vaddr + 100
 		@vaddr.last.value.must_equal(110)
 		@vaddr + -10
 		@vaddr.last.value.must_equal(100)
		@vaddr.+ 
 		@vaddr.last.value.must_equal(101)
 	end

 	it "should only + integers" do
 		lambda {@vaddr + 'A'}.must_raise(ArgumentError)
 		lambda {@vaddr + nil}.must_raise(ArgumentError)
 	end

 	it "does -" do
 		@vaddr.must_respond_to(:"-")
 		@vaddr << 10
 		@vaddr - 100
 		@vaddr.last.value.must_equal(-90)
 		@vaddr - -10
 		@vaddr.last.value.must_equal(-80)
 		@vaddr.- 
 		@vaddr.last.value.must_equal(-81)
 	end

 	it "should only - integers" do
 		lambda {@vaddr - 'A'}.must_raise(ArgumentError)
 		lambda {@vaddr - nil}.must_raise(ArgumentError)
 	end

 	it "only accepts integers" do
 		lambda {@vaddr << 10.0}.must_raise(ArgumentError)
 		lambda {@vaddr << nil}.must_raise(ArgumentError)
 	end

 	it "has last()" do
  		@vaddr.must_respond_to(:last)
 	end

 	it "remembers last value" do
 		@vaddr << 10
  		@vaddr.last.value.must_equal(10)
 		@vaddr << 1000
  		@vaddr.last.value.must_equal(1000)
 		@vaddr << 99
  		@vaddr.last.value.must_equal(99)
 		@vaddr << [10,0,190,100]
  		@vaddr.last.value.must_equal(100)
 	end

 	it "returns ordinal last" do
 		@vaddr << [10,9,8,7,6,5,4,3,2,1,0]
  		@vaddr.last(5).length.must_equal(5)
 	end

 	it "has max()" do
  		@vaddr.must_respond_to(:max)
 	end

 	it "does max()" do
 		@vaddr.clear_history!
 		@vaddr << [1,2,3,4,5]
 		@vaddr.max.must_equal(5)
 		@vaddr << 100
 		@vaddr.max.must_equal(100)
 		@vaddr << 100
 		@vaddr.max.must_equal(100)
 		@vaddr << 99
 		@vaddr.max.must_equal(100)
 		@vaddr << 0
 		@vaddr.max.must_equal(100)
 	end

 	it "does min()" do
 		@vaddr << [11,12,13,14,15]
 		@vaddr.min.must_equal(11)
 		@vaddr << 100
 		@vaddr.min.must_equal(11)
 		@vaddr << 10
 		@vaddr.min.must_equal(10)
 		@vaddr << 99
 		@vaddr.min.must_equal(10)
 		@vaddr << 0
 		@vaddr.min.must_equal(0)
 	end

 	it "does range" do
  		@vaddr.must_respond_to(:range)

  		ts = Time.now

  		@vaddr._insert(0,ts-1000)
  		@vaddr._insert(1,ts-1000)
  		@vaddr._insert(2,ts-1000)
  		@vaddr._insert(3,ts-1000)
  		@vaddr._insert(4,ts-1000)
  		@vaddr._insert(5,ts-800)
  		@vaddr._insert(6,ts-800)
  		@vaddr._insert(7,ts-800)
  		@vaddr._insert(8,ts-200)
  		@vaddr._insert(9,ts-10)
  		@vaddr._insert(10,ts-5)
 	  	@vaddr.range(ts-1000,ts).length.must_equal 11 
 	  	@vaddr.range(ts-800,ts).length.must_equal 6 
 	  	@vaddr.range(ts-200,ts).length.must_equal 3 
	  	@vaddr.range(ts-10,ts).length.must_equal 2 
	  	@vaddr.range(ts-5,ts).length.must_equal 1 
	  	@vaddr.range(ts-200,ts-11).length.must_equal 1 
	  	@vaddr.range(ts-1000,ts-1000).length.must_equal 5

 		@vaddr._insert(0,ts-100)
	  	@vaddr.range(ts-200,ts).length.must_equal 4 
	end

	it "does since" do
 		ts = Time.now

 		@vaddr._insert(0,ts-1000)
 		@vaddr._insert(7,ts-800)
 		@vaddr._insert(8,ts-200)
 		@vaddr._insert(10,ts-5)
 		@vaddr.must_respond_to(:since)
	  	values = @vaddr.since(ts-1000).length.must_equal(4) 
	  	values = @vaddr.since(ts-300).length.must_equal(2) 
	end

	it "does mq" do
		@board.flush_notification_queue
		@board.notification_queue_length.must_equal (0)

		pointers = []
	   	pointers << @board.values.addr(['0','1','2'])
	   	pointers << @board.values.addr(['0','1','3'])
	   	pointers << @board.values.addr(['0','1','4'])
	   	pointers << @board.values.addr(['0','1','5'])

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
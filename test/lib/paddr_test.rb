require 'test_helper'

describe Chawk::Paddr do
 	before do
 		@board = Chawk::Board.new()
   	@paddr = @board.points.addr(['a','b'])
   	@paddr.clear_history!
 	end

 	it "has path" do
  		@paddr.must_respond_to(:path)
 	end

 	it "has address" do
  		@paddr.must_respond_to(:address)
 	end

 	it "address is a/b" do
  		@paddr.address.must_equal("a/b")
 	   	@board.points.addr(['0','x','z']).address.must_equal("0/x/z")
  	end

  	it "rejects invalid paths" do
 		lambda {@board.points.addr('A')}.must_raise(ArgumentError)
 		lambda {@board.points.addr(0)}.must_raise(ArgumentError)
 		lambda {@board.points.addr(['/','x','z'])}.must_raise(ArgumentError)
 		lambda {@board.points.addr(['a/a','x','z'])}.must_raise(ArgumentError)
    lambda {@board.values.addr(['a','x',1])}.must_raise(ArgumentError)
    lambda {@board.values.addr(['a','x',:x])}.must_raise(ArgumentError)
    lambda{@board.values.addr ['a','x',Object.new] }.must_raise(ArgumentError)
  	end

 	it "has length" do
  		@paddr.must_respond_to(:length)
 	end

 	it "calculates length" do
 		@paddr.clear_history!
 		@paddr.length.must_equal(0)
 		@paddr << 2
 		@paddr.length.must_equal(1)
 		@paddr << 2
 		@paddr.length.must_equal(2)
 		@paddr << 2
 		@paddr.length.must_equal(3)
 		@paddr << [1,2,3,4]
 		@paddr.length.must_equal(7)
 	end

 	it "has clear_history!" do
  		@paddr.must_respond_to(:clear_history!)
 	end

 	it "clears history" do
 		@paddr.clear_history!
 		@paddr.length.must_equal(0)
 	end

 	it "accepts _insert" do
 		@paddr._insert(100,Time.now)
 		@paddr.length.must_equal(1)
 	end

 	it "accepts <<" do
 		@paddr.must_respond_to(:"<<")
 	end

 	it "accepts integers" do
 		@paddr << 10
 		@paddr.length.must_equal(1)
 		@paddr << 0
 		@paddr.length.must_equal(2)
 		@paddr << 190
 		@paddr << 10002
 		@paddr << [10,0,190,100]
 	end

 	it "does +" do
 		@paddr.must_respond_to(:"+")
 		@paddr << 10
 		@paddr + 100
 		@paddr.last.value.must_equal(110)
 		@paddr + -10
 		@paddr.last.value.must_equal(100)
		@paddr.+ 
 		@paddr.last.value.must_equal(101)
 	end

 	it "should only + integers" do
 		lambda {@paddr + 'A'}.must_raise(ArgumentError)
 		lambda {@paddr + nil}.must_raise(ArgumentError)
 	end

 	it "does -" do
 		@paddr.must_respond_to(:"-")
 		@paddr << 10
 		@paddr - 100
 		@paddr.last.value.must_equal(-90)
 		@paddr - -10
 		@paddr.last.value.must_equal(-80)
 		@paddr.- 
 		@paddr.last.value.must_equal(-81)
 	end

 	it "should only - integers" do
 		lambda {@paddr - 'A'}.must_raise(ArgumentError)
 		lambda {@paddr - nil}.must_raise(ArgumentError)
 	end

 	it "only accepts integers" do
 		lambda {@paddr << 10.0}.must_raise(ArgumentError)
 		lambda {@paddr << nil}.must_raise(ArgumentError)
    lambda {@paddr << [10.0,:x]}.must_raise(ArgumentError)
 	end

 	it "has last()" do
  		@paddr.must_respond_to(:last)
 	end

 	it "remembers last value" do
 		@paddr << 10
  		@paddr.last.value.must_equal(10)
 		@paddr << 1000
  		@paddr.last.value.must_equal(1000)
 		@paddr << 99
  		@paddr.last.value.must_equal(99)
 		@paddr << [10,0,190,100]
  		@paddr.last.value.must_equal(100)
 	end

 	it "returns ordinal last" do
 		@paddr << [10,9,8,7,6,5,4,3,2,1,0]
  	@paddr.last(5).length.must_equal(5)
 	end

 	it "has max()" do
  		@paddr.must_respond_to(:max)
 	end

 	it "does max()" do
 		@paddr.clear_history!
 		@paddr << [1,2,3,4,5]
 		@paddr.max.must_equal(5)
 		@paddr << 100
 		@paddr.max.must_equal(100)
 		@paddr << 100
 		@paddr.max.must_equal(100)
 		@paddr << 99
 		@paddr.max.must_equal(100)
 		@paddr << 0
 		@paddr.max.must_equal(100)
 	end

 	it "does min()" do
 		@paddr << [11,12,13,14,15]
 		@paddr.min.must_equal(11)
 		@paddr << 100
 		@paddr.min.must_equal(11)
 		@paddr << 10
 		@paddr.min.must_equal(10)
 		@paddr << 99
 		@paddr.min.must_equal(10)
 		@paddr << 0
 		@paddr.min.must_equal(0)
 	end

 	it :does_range do
  		@paddr.must_respond_to(:range)

  		ts = Time.now

  		@paddr._insert(0,ts-1000)
  		@paddr._insert(1,ts-1000)
  		@paddr._insert(2,ts-1000)
  		@paddr._insert(3,ts-1000)
  		@paddr._insert(4,ts-1000)
  		@paddr._insert(5,ts-800)
  		@paddr._insert(6,ts-800)
  		@paddr._insert(7,ts-800)
  		@paddr._insert(8,ts-200)
  		@paddr._insert(9,ts-10)
  		@paddr._insert(10,ts-5)
 	  	@paddr.range(ts-1000,ts).length.must_equal 11 
 	  	@paddr.range(ts-800,ts).length.must_equal 6 
 	  	@paddr.range(ts-200,ts).length.must_equal 3 
	  	@paddr.range(ts-10,ts).length.must_equal 2 
	  	@paddr.range(ts-5,ts).length.must_equal 1 
	  	@paddr.range(ts-200,ts-11).length.must_equal 1 
	  	@paddr.range(ts-1000,ts-1000).length.must_equal 5

 		@paddr._insert(0,ts-100)
	  	@paddr.range(ts-200,ts).length.must_equal 4 
	end

	it "does since" do
 		ts = Time.now

 		@paddr._insert(0,ts-1000)
 		@paddr._insert(7,ts-800)
 		@paddr._insert(8,ts-200)
 		@paddr._insert(10,ts-5)
 		@paddr.must_respond_to(:since)
  	@paddr.since(ts-1000).length.must_equal(4) 
  	@paddr.since(ts-300).length.must_equal(2) 
	end

  it :acts_like_an_integer do
    @paddr << 36878
    last = @paddr.last
    last.to_i.must_equal 36878
  end

	# it "does mq" do
	# 	@board.flush_notification_queue
	# 	@board.notification_queue_length.must_equal (0)

	# 	pointers = []
	#    	pointers << @board.points.addr(['0','1','2'])
	#    	pointers << @board.points.addr(['0','1','3'])
	#    	pointers << @board.points.addr(['0','1','4'])
	#    	pointers << @board.points.addr(['0','1','5'])

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
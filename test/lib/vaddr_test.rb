require 'test_helper'
require 'json'

describe Chawk::Vaddr do
 	before do
 		@board = Chawk::Board.new()
   	@vaddr = @board.values.addr(['a','b'])
   	@vaddr.clear_history!
 	end

  it "has consistent root" do
      rn = @vaddr.root_node
      @vaddr.root_node.must_equal rn
  end

 	it "has path" do
  		@vaddr.must_respond_to(:path)
 	end

 	it "has address" do
  		@vaddr.must_respond_to(:address)
 	end

 	it "address is a/b" do
  		@vaddr.address.must_equal("a/b")
      @board.points.addr(['a','b']).address.must_equal("a/b")
 	   	@board.values.addr(['0','x','z']).address.must_equal("0/x/z")
  	end

  	it "rejects invalid paths" do
 		lambda {@board.values.addr('A')}.must_raise(ArgumentError)
 		lambda {@board.values.addr(0)}.must_raise(ArgumentError)
 		lambda {@board.values.addr(['/','x','z'])}.must_raise(ArgumentError)
    lambda {@board.values.addr(['a/a','x','z'])}.must_raise(ArgumentError)
    lambda {@board.values.addr([0,2,2])}.must_raise(ArgumentError)
    lambda {@board.values.addr([:a,:b,:c])}.must_raise(ArgumentError)
    lambda {@board.values.addr([Object.new,Object.new,Object.new])}.must_raise(ArgumentError)
  	end

 	it "has length" do
  		@vaddr.must_respond_to(:length)
 	end

 	it :calculates_length do
 		@vaddr.clear_history!
 		@vaddr.length.must_equal(0)
 		@vaddr << "2"
 		@vaddr.length.must_equal(1)
 		@vaddr << "2"
 		@vaddr.length.must_equal(2)
 		@vaddr << "FLEAS!"
 		@vaddr.length.must_equal(3)
 		@vaddr << ["CAT","DOG","COW","CHIPMUNK"]
 		@vaddr.length.must_equal(7)
 	end

 	it "has clear_history!" do
  		@vaddr.must_respond_to(:clear_history!)
 	end

 	it "clears history" do
 		@vaddr.clear_history!
 		@vaddr.length.must_equal(0)
 	end

 	it :accepts__insert do
 		@vaddr._insert("SHOCK THE MONKEY",Time.now)
 		@vaddr.length.must_equal(1)
 	end

 	it "accepts <<" do
 		@vaddr.must_respond_to(:"<<")
 	end

 	it "accepts strings" do
 		@vaddr << "A"
 		@vaddr.length.must_equal(1)
 		@vaddr << "B"
 		@vaddr.length.must_equal(2)
 		@vaddr << "C"
 		@vaddr << "DDDD"
 		@vaddr << ["MY","DOG","HAS","FLEAS"]
 	end

 	it "only accepts strings" do
    lambda {@vaddr << 10}.must_raise(ArgumentError)
    lambda {@vaddr << 10.0}.must_raise(ArgumentError)
    lambda {@vaddr << Object.new}.must_raise(ArgumentError)
 		lambda {@vaddr << nil}.must_raise(ArgumentError)
    lambda {@vaddr << ["MY",:DOG,:HAS,:FLEAS]}.must_raise(ArgumentError)
    
 	end

 	it "has last()" do
  		@vaddr.must_respond_to(:last)
 	end

 	it "remembers last value" do
 		@vaddr << "ALL"
  		@vaddr.last.value.must_equal("ALL")
 		@vaddr << "GOOD"
  		@vaddr.last.value.must_equal("GOOD")
 		@vaddr << "BOYS"
  		@vaddr.last.value.must_equal("BOYS")
 		@vaddr << ["GO","TO","THE","FAIR"]
  		@vaddr.last.value.must_equal("FAIR")
 	end

 	it "returns ordinal last" do
 		@vaddr << ("a".."z").to_a
    @vaddr.last(5).length.must_equal(5)
 	end

 	it :does_range do
  		@vaddr.must_respond_to(:range)

  		ts = Time.now

  		@vaddr._insert('0',ts-1000)
  		@vaddr._insert('1',ts-1000)
  		@vaddr._insert('2',ts-1000)
  		@vaddr._insert('3',ts-1000)
  		@vaddr._insert('4',ts-1000)
  		@vaddr._insert('5',ts-800)
  		@vaddr._insert('6',ts-800)
  		@vaddr._insert('7',ts-800)
  		@vaddr._insert('8',ts-200)
  		@vaddr._insert('9',ts-10)
  		@vaddr._insert('10',ts-5)
 	  	@vaddr.range(ts-1000,ts).length.must_equal 11 
 	  	@vaddr.range(ts-800,ts).length.must_equal 6 
 	  	@vaddr.range(ts-200,ts).length.must_equal 3 
	  	@vaddr.range(ts-10,ts).length.must_equal 2 
	  	@vaddr.range(ts-5,ts).length.must_equal 1 
	  	@vaddr.range(ts-200,ts-11).length.must_equal 1 
	  	@vaddr.range(ts-1000,ts-1000).length.must_equal 5

   		@vaddr._insert('0',ts-100)
	  	@vaddr.range(ts-200,ts).length.must_equal 4 
	end

	it "does since" do
 		ts = Time.now

 		@vaddr._insert('0',ts-1000)
 		@vaddr._insert('7',ts-800)
 		@vaddr._insert('8',ts-200)
 		@vaddr._insert("10",ts-5)
 		@vaddr.must_respond_to(:since)
  	@vaddr.since(ts-1000).length.must_equal(4) 
  	@vaddr.since(ts-300).length.must_equal(2) 
	end

  it "handles serialized data" do
    serial = (1..100).collect{|x|"X" * (100)}.to_json
    @vaddr.<< serial
    last = @vaddr.last
    ary = JSON.parse(last)
    ary.length.must_equal 100
    ary[-1].must_equal ("X" * 100)
  end

  it :acts_like_a_string do
    @vaddr << "GET DOWN!"
    last = @vaddr.last
    last.to_s.must_equal ("GET DOWN!")
  end


	# it "does mq" do
	# 	@board.flush_notification_queue
	# 	@board.notification_queue_length.must_equal (0)

	# 	pointers = []
	#    	pointers << @board.values.addr(['0','1','2'])
	#    	pointers << @board.values.addr(['0','1','3'])
	#    	pointers << @board.values.addr(['0','1','4'])
	#    	pointers << @board.values.addr(['0','1','5'])

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
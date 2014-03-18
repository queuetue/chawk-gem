require 'test_helper'

describe Chawk::Paddr do
  before do
    #@board = Chawk::Board.new()
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
    @addr = Chawk.addr(@agent,'a:b')
    @addr.points.clear_history!
  end

 	it "has length" do
  		@addr.points.must_respond_to(:length)
 	end

 	it "calculates length" do
 		@addr.points.clear_history!
 		@addr.points.length.must_equal(0)
 		@addr.points << 2
 		@addr.points.length.must_equal(1)
 		@addr.points << 2
 		@addr.points.length.must_equal(2)
 		@addr.points << 2
 		@addr.points.length.must_equal(3)
 		@addr.points << [1,2,3,4]
 		@addr.points.length.must_equal(7)
 	end

 	it "has clear_history!" do
  		@addr.points.must_respond_to(:clear_history!)
 	end

 	it "clears history" do
 		@addr.points.clear_history!
 		@addr.points.length.must_equal(0)
 	end

 	it "accepts _insert" do
 		@addr.points._insert(100,Time.now)
 		@addr.points.length.must_equal(1)
 	end

 	it "accepts <<" do
 		@addr.points.must_respond_to(:"<<")
 	end

 	it "accepts integers" do
 		@addr.points << 10
 		@addr.points.length.must_equal(1)
 		@addr.points << 0
 		@addr.points.length.must_equal(2)
 		@addr.points << 190
 		@addr.points << 10002
    @addr.points << [10,0,190,100]
    dt = Time.now.to_f
    @addr.points << [[10,dt],[0,dt],[190,dt],[100,dt]]
    @addr.points << [{"v"=>10},{"v"=>0},{"v"=>190},{"v"=>100,"t"=>dt}]
    @addr.points << [{"v"=>10,"t"=>dt},{"v"=>0,"t"=>dt},{"v"=>190,"t"=>dt},{"v"=>100,"t"=>dt}]
    @addr.points << [{"t"=>dt,"v"=>10},{"v"=>0,"t"=>dt},{"t"=>dt,"v"=>190},{"v"=>100,"t"=>dt}]
 	end

 	it "does +" do
 		@addr.points.must_respond_to(:"+")
 		@addr.points << 10
 		@addr.points + 100
 		@addr.points.last.value.must_equal(110)
 		@addr.points + -10
 		@addr.points.last.value.must_equal(100)
		@addr.points.+ 
 		@addr.points.last.value.must_equal(101)
 	end

 	it "should only + integers" do
 		lambda {@addr.points + 'A'}.must_raise(ArgumentError)
 		lambda {@addr.points + nil}.must_raise(ArgumentError)
 	end

 	it "does -" do
 		@addr.points.must_respond_to(:"-")
 		@addr.points << 10
 		@addr.points - 100
 		@addr.points.last.value.must_equal(-90)
 		@addr.points - -10
 		@addr.points.last.value.must_equal(-80)
 		@addr.points.- 
 		@addr.points.last.value.must_equal(-81)
 	end

 	it "should only - integers" do
 		lambda {@addr.points - 'A'}.must_raise(ArgumentError)
 		lambda {@addr.points - nil}.must_raise(ArgumentError)
 	end

 	it "only accepts integers in proper formats" do
 		lambda {@addr.points << 10.0}.must_raise(ArgumentError)
 		lambda {@addr.points << nil}.must_raise(ArgumentError)
    lambda {@addr.points << [10.0,:x]}.must_raise(ArgumentError)
    lambda {@addr.points << [[10,10,10],[10,10,20]]}.must_raise(ArgumentError)
    dt = Time.now.to_f
    lambda {@addr.points << [{"x"=>10,"t"=>dt},{"x"=>0,"t"=>dt}]}.must_raise(ArgumentError)
 	end

  it "does bulk add points" do
    dt = Time.now.to_f
    Chawk.bulk_add_points(@agent, {"xxx"=>[1,2,3,4,5,6], "yyy"=>[[10,dt],[10,dt]], "zzz"=>[{"t"=>dt,"v"=>10},{"v"=>0,"t"=>dt}]})

    Chawk.addr(@agent,"xxx").points.length.must_equal 6
    Chawk.addr(@agent,"zzz").points.length.must_equal 2
    Chawk.addr(@agent,"zzz").points.last.value.must_equal 0

  end

 	it "has last()" do
  		@addr.points.must_respond_to(:last)
 	end

 	it "remembers last value" do
 		@addr.points << 10
  		@addr.points.last.value.must_equal(10)
 		@addr.points << 1000
  		@addr.points.last.value.must_equal(1000)
 		@addr.points << 99
  		@addr.points.last.value.must_equal(99)
 		@addr.points << [10,0,190,100]
  		@addr.points.last.value.must_equal(100)
 	end

 	it "returns ordinal last" do
 		@addr.points << [10,9,8,7,6,5,4,3,2,1,0]
  	@addr.points.last(5).length.must_equal(5)
 	end

 	it "has max()" do
  		@addr.points.must_respond_to(:max)
 	end

 	it "does max()" do
 		@addr.points.clear_history!
 		@addr.points << [1,2,3,4,5]
 		@addr.points.max.must_equal(5)
 		@addr.points << 100
 		@addr.points.max.must_equal(100)
 		@addr.points << 100
 		@addr.points.max.must_equal(100)
 		@addr.points << 99
 		@addr.points.max.must_equal(100)
 		@addr.points << 0
 		@addr.points.max.must_equal(100)
 	end

 	it "does min()" do
 		@addr.points << [11,12,13,14,15]
 		@addr.points.min.must_equal(11)
 		@addr.points << 100
 		@addr.points.min.must_equal(11)
 		@addr.points << 10
 		@addr.points.min.must_equal(10)
 		@addr.points << 99
 		@addr.points.min.must_equal(10)
 		@addr.points << 0
 		@addr.points.min.must_equal(0)
 	end

 	it :does_range do
  		@addr.points.must_respond_to(:range)

  		ts = Time.now

  		@addr.points._insert(0,ts-1000)
  		@addr.points._insert(1,ts-1000)
  		@addr.points._insert(2,ts-1000)
  		@addr.points._insert(3,ts-1000)
  		@addr.points._insert(4,ts-1000)
  		@addr.points._insert(5,ts-800)
  		@addr.points._insert(6,ts-800)
  		@addr.points._insert(7,ts-800)
  		@addr.points._insert(8,ts-200)
  		@addr.points._insert(9,ts-10)
  		@addr.points._insert(10,ts-5)
 	  	@addr.points.range(ts-1000,ts).length.must_equal 11 
 	  	@addr.points.range(ts-800,ts).length.must_equal 6 
 	  	@addr.points.range(ts-200,ts).length.must_equal 3 
	  	@addr.points.range(ts-10,ts).length.must_equal 2 
	  	@addr.points.range(ts-5,ts).length.must_equal 1 
	  	@addr.points.range(ts-200,ts-11).length.must_equal 1 
	  	@addr.points.range(ts-1000,ts-1000).length.must_equal 5

 		@addr.points._insert(0,ts-100)
	  	@addr.points.range(ts-200,ts).length.must_equal 4 
	end

	it "does since" do
 		ts = Time.now

 		@addr.points._insert(0,ts-1000)
 		@addr.points._insert(7,ts-800)
 		@addr.points._insert(8,ts-200)
 		@addr.points._insert(10,ts-5)
 		@addr.points.must_respond_to(:since)
  	@addr.points.since(ts-1000).length.must_equal(4) 
  	@addr.points.since(ts-300).length.must_equal(2) 
	end

  # it :acts_like_an_integer do
  #   @addr.points << 36878
  #   last = @addr.points.last
  #   last.to_i.must_equal 36878
  # end

	# it "does mq" do
	# 	@board.flush_notification_queue
	# 	@board.notification_queue_length.must_equal (0)

	# 	pointers = []
	#    	pointers << @board.paddr(['0','1','2'])
	#    	pointers << @board.paddr(['0','1','3'])
	#    	pointers << @board.paddr(['0','1','4'])
	#    	pointers << @board.paddr(['0','1','5'])

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
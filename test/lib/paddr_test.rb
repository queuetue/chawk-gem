require 'test_helper'

describe Chawk do
  before do
    Chawk.clear_all_data!
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
    @addr = Chawk.addr(@agent,'a:b')
  end

 	it "has length" do
   		@addr.points.must_respond_to(:length)
 	end

 	it "calculates length" do
 		@addr.points.destroy_all
 		@addr.points.length.must_equal(0)
 		@addr.add_points 2
 		@addr.points.length.must_equal(1)
 		@addr.add_points 2
 		@addr.points.length.must_equal(2)
 		@addr.add_points 2
 		@addr.points.length.must_equal(3)
 		@addr.add_points [1,2,3,4]
 		@addr.points.length.must_equal(7)
 	end

 	it "clears points" do
   		@addr.must_respond_to(:clear_points!)
 	 end

 	it "clears history" do
	  @addr.add_points [1,2,3,4]
 		@addr.points.length.must_equal(4)
    @addr.clear_points!
 		@addr.points.length.must_equal(0)
 	end

 	it "doesn't clear the wrong history" do
	    addr2 = Chawk.addr(@agent,'a:b')
	    addr2.points.destroy_all
 		@addr.points.destroy_all
	    addr2.add_points [1,2,3,4]
	    @addr.add_points [1,2,3,4]
	    addr2.points.destroy_all
 		addr2.points.length.must_equal(0)
 		@addr.points.length.must_equal(4)
 	end

 	it "accepts _insert_point" do
 		@addr._insert_point(100,Time.now)
 		@addr.points.length.must_equal(1)
 	end

 	it "accepts add_points" do
 		@addr.must_respond_to(:"add_points")
 	end

 	it "accepts integers" do
 		@addr.add_points 10
 		@addr.points.length.must_equal(1)
 		@addr.add_points 0
 		@addr.points.length.must_equal(2)
 		@addr.add_points 190
 		@addr.add_points 10002
    @addr.add_points [10,0,190,100]
    dt = Time.now.to_f
    @addr.add_points [[10,dt],[0,dt],[190,dt],[100,dt]]
    @addr.add_points [{"v"=>10},{"v"=>0},{"v"=>190},{"v"=>100,"t"=>dt}]
    @addr.add_points [{"v"=>10,"t"=>dt},{"v"=>0,"t"=>dt},{"v"=>190,"t"=>dt},{"v"=>100,"t"=>dt}]
    @addr.add_points [{"t"=>dt,"v"=>10},{"v"=>0,"t"=>dt},{"t"=>dt,"v"=>190},{"v"=>100,"t"=>dt}]
 	end

 	it "does increment" do
 		@addr.points.destroy_all
	    @addr.add_points 99
 		@addr.must_respond_to(:increment)
 		@addr.increment 10
 		@addr.increment
 		@addr.points.last.value.must_equal(110)
 		@addr.increment -10
 		@addr.points.last.value.must_equal(100)
		@addr.increment 
 		@addr.points.last.value.must_equal(101)
 	end

 	it "should only increment integers" do
 		lambda {@addr.increment 'A'}.must_raise(ArgumentError)
 		lambda {@addr.increment nil}.must_raise(ArgumentError)
 	end

 	it "does -" do
 		@addr.points.must_respond_to(:"-")
 		@addr.add_points 10
 		@addr.decrement 100
 		@addr.points.last.value.must_equal(-90)
 		@addr.decrement -10
 		@addr.points.last.value.must_equal(-80)
 		@addr.decrement
 		@addr.points.last.value.must_equal(-81)
 	end

 	it "should only - integers" do
 		lambda {@addr.decrement 'A'}.must_raise(ArgumentError)
 		lambda {@addr.decrement nil}.must_raise(ArgumentError)
 	end

 	it "only accepts integers in proper formats" do
 		lambda {@addr.add_points 10.0}.must_raise(ArgumentError)
 		lambda {@addr.add_points nil}.must_raise(ArgumentError)
    lambda {@addr.add_points [10.0,:x]}.must_raise(ArgumentError)
    lambda {@addr.add_points [[10,10,10],[10,10,20]]}.must_raise(ArgumentError)
    dt = Time.now.to_f
    lambda {@addr.add_points [{"x"=>10,"t"=>dt},{"x"=>0,"t"=>dt}]}.must_raise(ArgumentError)
 	end

  it "accepts string integers in proper formats" do
    lambda {@addr.add_points "X"}.must_raise(ArgumentError)
    @addr.add_points "10"
    @addr.points.length.must_equal(1)
    @addr.add_points "0"
    @addr.points.length.must_equal(2)
    @addr.add_points "190"
    @addr.add_points "10002"
    @addr.add_points ["10","0","190","100"]
    @addr.points.length.must_equal(8)
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
 		@addr.add_points 10
  		@addr.points.last.value.must_equal(10)
 		@addr.add_points 1000
  		@addr.points.last.value.must_equal(1000)
 		@addr.add_points 99
  		@addr.points.last.value.must_equal(99)
 		@addr.add_points [10,0,190,100]
  		@addr.points.last.value.must_equal(100)
 	end

  it "stores meta information" do

    metadata = {"info"=>"this is a test"}
    @addr.add_points([1,2,3,4],{:meta=>metadata})
    @addr.points.last.value.must_equal(4)
    meta = @addr.points.last.meta
    JSON.parse(meta).must_equal(metadata)

    metadata = {"number"=>123}
    @addr.add_points([1,2,3,4],{:meta=>metadata})
    @addr.points.last.value.must_equal(4)
    JSON.parse(@addr.points.last.meta).must_equal(metadata)

    metadata = ["completely wrong"]
    lambda {@addr.add_points([1,2,3,4],{:meta=>metadata})}.must_raise(ArgumentError)

  end


 	it "returns ordinal last" do
 		@addr.add_points [10,9,8,7,6,5,4,3,2,1,0]
  	@addr.points.last(5).length.must_equal(5)
 	end

 	# it "has max()" do
  # 		@addr.must_respond_to(:max)
 	# end

 	# it "does max()" do
 	# 	@addr.points.destroy_all
 	# 	@addr.add_points [1,2,3,4,5]
 	# 	@addr.max.must_equal(5)
 	# 	@addr.add_points 100
 	# 	@addr.max.must_equal(100)
 	# 	@addr.add_points 100
 	# 	@addr.max.must_equal(100)
 	# 	@addr.add_points 99
 	# 	@addr.max.must_equal(100)
 	# 	@addr.add_points 0
 	# 	@addr.max.must_equal(100)
 	# end

 	# it "does min()" do
 	# 	@addr.add_points [11,12,13,14,15]
 	# 	@addr.min.must_equal(11)
 	# 	@addr.add_points 100
 	# 	@addr.min.must_equal(11)
 	# 	@addr.add_points 10
 	# 	@addr.min.must_equal(10)
 	# 	@addr.add_points 99
 	# 	@addr.min.must_equal(10)
 	# 	@addr.add_points 0
 	# 	@addr.min.must_equal(0)
 	# end

 	it :does_range do
  		@addr.must_respond_to(:points_range)

  		ts = Time.now

  		@addr._insert_point(0,ts-1000)
  		@addr._insert_point(1,ts-1000)
  		@addr._insert_point(2,ts-1000)
  		@addr._insert_point(3,ts-1000)
  		@addr._insert_point(4,ts-1000)
  		@addr._insert_point(5,ts-800)
  		@addr._insert_point(6,ts-800)
  		@addr._insert_point(7,ts-800)
  		@addr._insert_point(8,ts-200)
  		@addr._insert_point(9,ts-10)
  		@addr._insert_point(10,ts-5)
 	  	@addr.points_range(ts-1001,ts).length.must_equal 11 
 	  	@addr.points_range(ts-801,ts).length.must_equal 6 
 	  	@addr.points_range(ts-201,ts).length.must_equal 3 
	  	@addr.points_range(ts-11,ts).length.must_equal 2 
	  	@addr.points_range(ts-6,ts).length.must_equal 1 
	  	@addr.points_range(ts-201,ts-11).length.must_equal 1 
	  	@addr.points_range(ts-1001,ts-999).length.must_equal 5

   		@addr._insert_point(0,ts-101)
	  	@addr.points_range(ts-201,ts).length.must_equal 4 
	end

	it "does since" do
    @addr.points.destroy_all


 		ts = Time.now

 		@addr._insert_point(0,ts-1000)
 		@addr._insert_point(7,ts-800)
 		@addr._insert_point(8,ts-200)
 		@addr._insert_point(10,ts-5)
 		@addr.must_respond_to(:points_since)
  	@addr.points_since(ts-1001).length.must_equal(4) 
  	@addr.points_since(ts-301).length.must_equal(2) 
	end

end
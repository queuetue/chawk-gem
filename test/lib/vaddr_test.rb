 require 'test_helper'
 require 'json'

describe Chawk do
 	before do
    Chawk.clear_all_data!
	@agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
	@addr = Chawk.addr(@agent,'a:b')
   	@addr.clear_values!
 	end

 	it "has length" do
  		@addr.values.must_respond_to(:length)
 	end

	it :calculates_length do
		@addr.clear_values!
		@addr.values.length.must_equal(0)
		@addr.add_values "2"
		@addr.values.length.must_equal(1)
		@addr.add_values "2"
		@addr.values.length.must_equal(2)
		@addr.add_values "FLEAS!"
		@addr.values.length.must_equal(3)
		@addr.add_values ["CAT","DOG","COW","CHIPMUNK"]
		@addr.values.length.must_equal(7)
	end

	it "clears history" do
    	@addr.add_values ["CLAM", "FISH","SEAHORSE","AQUAMAN","WET TIGER"]
    	@addr.values.length.must_equal(5)
		@addr.clear_values!
		@addr.values.length.must_equal(0)
	end

	it "accepts _insert_value" do
		@addr._insert_value("SHOCK THE MONKEY",Time.now)
		@addr.values.length.must_equal(1)
	end

	it "accepts add_value" do
		@addr.must_respond_to(:"add_values")
	end

	it "accepts strings" do
		@addr.add_values "A"
		@addr.values.length.must_equal(1)
		@addr.add_values "B"
		@addr.values.length.must_equal(2)
		@addr.add_values "C"
		@addr.add_values "DDDD"
		@addr.add_values ["MY","DOG","HAS","FLEAS"]
	end

	it "only accepts strings" do
		lambda {@addr.add_values 10}.must_raise(ArgumentError)
		lambda {@addr.add_values 10.0}.must_raise(ArgumentError)
		lambda {@addr.add_values Object.new}.must_raise(ArgumentError)
		lambda {@addr.add_values nil}.must_raise(ArgumentError)
		lambda {@addr.add_values ["MY",:DOG,:HAS,:FLEAS]}.must_raise(ArgumentError)
	end

	it "has last()" do
		@addr.values.must_respond_to(:last)
	end

	it "remembers last value" do
		@addr.add_values "ALL"
		@addr.values.last.value.must_equal("ALL")
		@addr.add_values "GOOD"
		@addr.values.last.value.must_equal("GOOD")
		@addr.add_values "BOYS"
		@addr.values.last.value.must_equal("BOYS")
		@addr.add_values ["GO","TO","THE","FAIR"]
		@addr.values.last.value.must_equal("FAIR")
	end

	it "returns ordinal last" do
		@addr.add_values ("a".."z").to_a
		@addr.values.last(5).length.must_equal(5)
	end

	it :does_range do
	@addr.must_respond_to(:values_range)

	ts = Time.now
		@addr._insert_value('0',ts-1000)
		@addr._insert_value('1',ts-1000)
		@addr._insert_value('2',ts-1000)
		@addr._insert_value('3',ts-1000)
		@addr._insert_value('4',ts-1000)
		@addr._insert_value('5',ts-800)
		@addr._insert_value('6',ts-800)
		@addr._insert_value('7',ts-800)
		@addr._insert_value('8',ts-200)
		@addr._insert_value('9',ts-10)
		@addr._insert_value('10',ts-5)
		@addr.values_range(ts-1001,ts).length.must_equal 11 
		@addr.values_range(ts-801,ts).length.must_equal 6 
		@addr.values_range(ts-201,ts).length.must_equal 3 
		@addr.values_range(ts-11,ts).length.must_equal 2 
		@addr.values_range(ts-6,ts).length.must_equal 1 
		@addr.values_range(ts-201,ts-11).length.must_equal 1 
		@addr.values_range(ts-1001,ts-990).length.must_equal 5

		@addr._insert_value('0',ts-100)
		@addr.values_range(ts-201,ts).length.must_equal 4 
	end

	it "does since" do
		ts = Time.now
    @addr.must_respond_to(:values_since)
		@addr._insert_value('0',ts-1000)
		@addr._insert_value('7',ts-800)
		@addr._insert_value('8',ts-200)
		@addr._insert_value("10",ts-5)
		@addr.values_since(ts-1001).length.must_equal(4) 
		@addr.values_since(ts-301).length.must_equal(2) 
	end

	it "handles serialized data" do
		serial = (1..100).collect{|x|"X" * (100)}.to_json
		@addr.add_values serial
		last = @addr.values.last
		ary = JSON.parse(last.value.to_s)
		ary.length.must_equal 100
		ary[-1].must_equal ("X" * 100)
	end

end
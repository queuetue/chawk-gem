require 'spec_helper'

describe Chawk::SqlitePoint do
end

describe Chawk::SqlitePointer do
	pointer = nil
	before :each do
    	pointer = Chawk::SqlitePointer.new(['a','b'])
    	#puts pointer
    end

	it "has address()" do
 		pointer.should respond_to(:address)
	end

	it "address is a/b" do
 		pointer.address.should eq("a/b")
	   	Chawk::SqlitePointer.new(['0','x','z']).address.should eq("0/x/z")
 	end

 	it "rejects invalid paths" do
		lambda {Chawk::SqlitePointer.new('A')}.should raise_error()
		lambda {Chawk::SqlitePointer.new(0)}.should raise_error()
		lambda {Chawk::SqlitePointer.new(['/','x','z'])}.should raise_error()
		lambda {Chawk::SqlitePointer.new(['a/a','x','z'])}.should raise_error()
 	end

	it "accepts <<" do
		pointer.should respond_to(:"<<")
	end

	it "accepts integers" do
		lambda {pointer << 10}.should_not raise_error()
		lambda {pointer << 0}.should_not raise_error()
		lambda {pointer << 190}.should_not raise_error()
		lambda {pointer << 10000}.should_not raise_error()
		lambda {pointer << [10,0,190,10000]}.should_not raise_error()
	end

	it "accepts points" do
		lambda {pointer << 10}.should_not raise_error()
		lambda {pointer << 0}.should_not raise_error()
		lambda {pointer << 190}.should_not raise_error()
		lambda {pointer << 10000}.should_not raise_error()
		lambda {pointer << [10,0,190,10000]}.should_not raise_error()
	end


	it "has +" do
		pointer.should respond_to(:"+")
	end

	it "should only + integers" do
		lambda {pointer + 'A'}.should raise_error()
		lambda {pointer + nil}.should raise_error()
	end

	it "does +" do
		pointer << 10
		pointer + 100
		pointer.last.value.should eq(110)
		pointer + -10
		pointer.last.value.should eq(100)
		pointer.+ 
		pointer.last.value.should eq(101)
	end

	it "has -" do
		pointer.should respond_to(:"-")
	end

	it "should only - integers" do
		lambda {pointer - 'A'}.should raise_error()
		lambda {pointer - nil}.should raise_error()
	end


	it "does -" do
		pointer << 10
		pointer - 100
		pointer.last.value.should eq(-90)
		pointer - -10
		pointer.last.value.should eq(-80)
		pointer.- 
		pointer.last.value.should eq(-81)
	end

	it "only accepts integers" do
		lambda {pointer << 10.0}.should raise_error()
		lambda {pointer << nil}.should raise_error()
	end

	it "has last()" do
 		pointer.should respond_to(:last)
	end

	it "remembers last value" do
		pointer << 10
 		pointer.last.value.should eq(10)
		pointer << 1000
 		pointer.last.value.should eq(1000)
		pointer << 99
 		pointer.last.value.should eq(99)
		pointer << [10,0,190,10000]
 		pointer.last.value.should eq(10000)
	end

	it "has clear_history!()" do
 		pointer.should respond_to(:clear_history!)
	end

	it "has length()" do
 		pointer.should respond_to(:length)
	end

	it "clears history" do
		lambda {pointer.clear_history!}.should_not raise_error()
		pointer.length.should eq(0)
	end

	it "calculates length" do
		pointer.clear_history!
		pointer.length.should eq(0)
		pointer << 2
		pointer.length.should eq(1)
		pointer << 2
		pointer.length.should eq(2)
		pointer << 2
		pointer.length.should eq(3)
		pointer << [1,2,3,4]
		pointer.length.should eq(7)
	end

	it "has max()" do
 		pointer.should respond_to(:max)
	end

	it "does max()" do
		pointer.clear_history!
		pointer << [1,2,3,4,5]
		pointer.max.value.should eq(5)
		pointer << 100
		pointer.max.value.should eq(100)
		pointer << 100
		pointer.max.value.should eq(100)
		pointer << 99
		pointer.max.value.should eq(100)
		pointer << 0
		pointer.max.value.should eq(100)
	end

	it "does min()" do
		pointer.clear_history!
		pointer << [11,12,13,14,15]
		pointer.min.value.should eq(11)
		pointer << 100
		pointer.min.value.should eq(11)
		pointer << 10
		pointer.min.value.should eq(10)
		pointer << 99
		pointer.min.value.should eq(10)
		pointer << 0
		pointer.min.value.should eq(0)
	end

end
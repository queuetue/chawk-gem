require 'spec_helper'

describe Chawk do
	pointer = nil
	before :each do
    	pointer = Chawk::Pointer.new(['a','b'])
    	puts pointer
    end

	it "has address()" do
 		pointer.should respond_to(:address)
	end

	it "address is a/b" do
 		pointer.address.should eq("a/b")
    	Chawk::Pointer.new(['0','x','z']).address.should eq("0/x/z")
	end

	it "accepts <<" do
		pointer.should respond_to(:"<<")
	end

	it "accepts integers" do
		lambda {pointer << 10}.should_not raise_error()
		lambda {pointer << 0}.should_not raise_error()
		lambda {pointer << 190}.should_not raise_error()
		lambda {pointer << 10000}.should_not raise_error()
	end

	it "only accepts integers" do
		lambda {pointer << 10.0}.should raise_error()
		lambda {pointer << nil}.should raise_error()
		lambda {pointer << []}.should raise_error()
	end

	it "has last()" do
 		pointer.should respond_to(:last)
	end

	it "remembers last value" do
		pointer << 10
 		pointer.last.should eq(10)
		pointer << 1000
 		pointer.last.should eq(1000)
		pointer << 99
 		pointer.last.should eq(99)
	end

end
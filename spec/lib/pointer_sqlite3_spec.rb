require 'spec_helper'
filename = "./test.sqlite3"

describe Chawk::SqliteChawkboard do
	before :all do
		File.delete(filename) if File.exist?(filename)
	end

	after :all do
		File.delete(filename) if File.exist?(filename)
	end

	it "prevents database mismatch" do
		lambda {Chawk::SqliteChawkboard.new(filename)}.should_not raise_error()
		Chawk::SqliteChawkboard.new(filename,{IGNORE_DB_PROTOCOL:true}).set_db_version "testing-XX"
		lambda {Chawk::SqliteChawkboard.new(filename)}.should raise_error()
	end
end

describe Chawk::SqlitePointer do
	pointer = nil
	board = nil

	before :all do
		File.delete(filename) if File.exist?(filename)
		board = Chawk::SqliteChawkboard.new(filename)
	end
	before :each do
    	pointer = board.get_pointer(['a','b'])
    	#puts pointer
    end

    it "has version()" do
 		pointer.should respond_to(:version)
		lambda {pointer.version}.should_not raise_error()
    end

	it "has address()" do
 		pointer.should respond_to(:address)
	end

	it "address is a/b" do
		#puts "X#{pointer.address()}Y"
 		pointer.address.should eq("a/b")
	   	board.get_pointer(['0','x','z']).address.should eq("0/x/z")
 	end

 	it "rejects invalid paths" do
		lambda {board.get_pointer('A')}.should raise_error()
		lambda {board.get_pointer(0)}.should raise_error()
		lambda {board.get_pointer(['/','x','z'])}.should raise_error()
		lambda {board.get_pointer(['a/a','x','z'])}.should raise_error()
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

	it "returns ordinal last" do
		pointer << [10,9,8,7,6,5,4,3,2,1,0]
 		pointer.last(5).length.should eq(5)
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

	it "does range" do
 		pointer.should respond_to(:range)

	  	values = pointer.range(Time.now-2,Time.now)
	  	expect(values.length).to be > (2) 

		pointer << 1
		pointer << 2
		pointer << 3
		pointer << 4

	  	values = pointer.range(Time.now-2,Time.now)
	  	#puts values

		#payload_data = values.inject([]) do |result,d|
		#	puts "D: #{d}"
		#	result << {x:d.timestamp,y:d.value}
		#end


	  	#puts values

	  	values[-1].value.should eq(4)
	  	values[-2].value.should eq(3)
	  	values[-3].value.should eq(2)
	  	values[-4].value.should eq(1)

	  	# TODO: disabled because wait is annoying
	  	# reimpliment with passed-in timestamp
 		#sleep(1)

		#pointer << 1
		#pointer << 2

	  	#values = pointer.range(Time.now-0.5,Time.now)
	  	#values.length.should eq(2) 

	end

	it "does since" do
	  	# TODO: disabled because wait (from range test) is annoying
	  	# reimpliment with passed-in timestamp
 		#pointer.should respond_to(:since)
	  	#values = pointer.since(Time.now-1)
	  	#values.length.should eq(2) 
	end

	it "does mq" do
		board.flush_notification_queue
		board.notification_queue_length.should eq (0)

		pointers = []
	   	pointers << board.get_pointer(['0','1','2'])
	   	pointers << board.get_pointer(['0','1','3'])
	   	pointers << board.get_pointer(['0','1','4'])
	   	pointers << board.get_pointer(['0','1','5'])

	   	pointers.each{|p|p<<10}

		board.notification_queue_length.should eq (4)
		x = board.pop_from_notification_queue
		x.should eq([1,"0/1/2",8])
		board.notification_queue_length.should eq (3)
		x = board.pop_from_notification_queue
		x = board.pop_from_notification_queue
		board.notification_queue_length.should eq (1)
		x.should eq([3,"0/1/4",10])
	end


end
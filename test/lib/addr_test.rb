require 'test_helper'
require 'json'

describe Chawk::Addr do
 	before do
 		@board = Chawk::Board.new()
   	@addr = @board.addr(['a','b'])
 	end

  it "has consistent root" do
      rn = @addr.root_node
      @addr.root_node.must_equal rn
  end

 	it "has path" do
  		@addr.must_respond_to(:path)
 	end

 	it "has address" do
  		@addr.must_respond_to(:address)
 	end

 	it "address is a/b" do
  		@addr.address.must_equal("a/b")
      @board.addr(['a','b']).address.must_equal("a/b")
 	   	@board.addr(['0','x','z']).address.must_equal("0/x/z")
  	end

  it "rejects invalid paths" do
    lambda {@board.addr('A')}.must_raise(ArgumentError)
    lambda {@board.addr(0)}.must_raise(ArgumentError)
    lambda {@board.addr(['/','x','z'])}.must_raise(ArgumentError)
    lambda {@board.addr(['a/a','x','z'])}.must_raise(ArgumentError)
    lambda {@board.addr([0,2,2])}.must_raise(ArgumentError)
    lambda {@board.addr([:a,:b,:c])}.must_raise(ArgumentError)
    lambda {@board.addr([Object.new,Object.new,Object.new])}.must_raise(ArgumentError)
  end
end

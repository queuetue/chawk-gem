require 'test_helper'
require 'json'

describe Chawk::Addr do
 	before do
 		@board = Chawk::Board.new()
    @agent = Chawk::Models::Agent.create(:name=>"Test User")
    @addr = @board.addr(@agent,['a','b'])
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
      @board.addr(@agent,['a','b']).address.must_equal("a/b")
 	   	@board.addr(@agent,['0','x','z']).address.must_equal("0/x/z")
  	end

  it "rejects invalid paths" do
    lambda {@board.addr(@agent,'A')}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,0)}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,['/','x','z'])}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,['a/a','x','z'])}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,[0,2,2])}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,[:a,:b,:c])}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,[Object.new,Object.new,Object.new])}.must_raise(ArgumentError)
  end
end

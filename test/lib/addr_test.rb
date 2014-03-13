require 'test_helper'
require 'json'

describe Chawk::Addr do
  before do
    @board = Chawk::Board.new()
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
    @addr = @board.addr(@agent,'a/b')
  end

  it "has path" do
   @addr.must_respond_to(:path)
  end

  it "has address" do
    @addr.must_respond_to(:address)
  end

  it "address is a/b" do
    @addr.address.must_equal("a/b")
    @board.addr(@agent,'a/b').address.must_equal("a/b")
    @board.addr(@agent,'0/x/z').address.must_equal("0/x/z")
  end

  it "rejects invalid paths" do
    lambda {@board.addr(@agent,['A'])}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,0)}.must_raise(ArgumentError)
    #lambda {@board.addr(@agent,"a\na")}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,:a)}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,Object.new)}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,String.new)}.must_raise(ArgumentError)
    lambda {@board.addr(@agent,"")}.must_raise(ArgumentError)
  end

  it "stops unauthorized access" do
    @agent2 = Chawk::Models::Agent.create(name:"Steve Austin")
    lambda{@addr = @board.addr(@agent2,'a/b')}.must_raise SecurityError
  end

end

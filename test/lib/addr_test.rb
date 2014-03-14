require 'test_helper'
require 'json'

describe Chawk::Addr do
  before do
    Chawk.clear_all_data!
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
    @addr = Chawk.addr(@agent,'a/b')
  end

  it "has path" do
   @addr.must_respond_to(:path)
  end

  it "has address" do
    @addr.must_respond_to(:address)
  end

  it "address is a/b" do
    @addr.address.must_equal("a/b")
    Chawk.addr(@agent,'a/b').address.must_equal("a/b")
    Chawk.addr(@agent,'0/x/z').address.must_equal("0/x/z")
  end

  it "rejects invalid paths" do
    lambda {Chawk.addr(@agent,['A'])}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,0)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,:a)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,Object.new)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,String.new)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,"")}.must_raise(ArgumentError)
  end

  it "stops unauthorized access" do
    agent2 = Chawk::Models::Agent.first(name:"Steve Austin") || Chawk::Models::Agent.create(name:"Steve Austin")
    lambda{@addr = Chawk.addr(agent2,'a/b')}.must_raise SecurityError
    @addr.public_read=true
    Chawk.addr(agent2,'a/b').address.must_equal "a/b"
    @addr.public_read=false
    lambda{@addr = Chawk.addr(agent2,'a/b')}.must_raise SecurityError
    @addr.set_permissions(agent2,true,false,false)
    Chawk.addr(agent2,'a/b').address.must_equal "a/b"
    @addr.set_permissions(agent2,false,false,false)
    lambda{@addr = Chawk.addr(agent2,'a/b')}.must_raise SecurityError
    @addr.set_permissions(agent2,false,false,true)
    Chawk.addr(agent2,'a/b').address.must_equal "a/b"
  end

end

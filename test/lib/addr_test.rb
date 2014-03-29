require 'test_helper'
require 'json'

describe Chawk do
  before do
    Chawk.clear_all_data!
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
    @addr = Chawk.addr(@agent,'a:b')
  end

  it "has a good agent" do
    lambda {Chawk.addr(nil,'a:b')}.must_raise(ArgumentError)
    lambda {Chawk.addr(Object.new,'a:b')}.must_raise(ArgumentError)
    lambda {Chawk.addr(Chawk::Models::Agent,'a:b')}.must_raise(ArgumentError)
    addr = Chawk.addr(@agent,'a:b').key.must_equal("a:b")
    agent2 =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
    addr = Chawk.addr(agent2,'a:b').key.must_equal("a:b")
    agent3 =  Chawk::Models::Agent.create(:name=>"Test Failer")
    lambda{Chawk.addr(agent3,'a:b').key.must_equal("a:b")}.must_raise(SecurityError)
  end

  it "has key" do
   @addr.must_respond_to(:key)
  end

  it "key is valid" do
    @addr.key.must_equal("a:b")
    Chawk.addr(@agent,'a:b').key.must_equal("a:b")
    Chawk.addr(@agent,'0:x:z').key.must_equal("0:x:z")
    path = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345689_:$!@*[]~()"
    Chawk.addr(@agent,path).key.must_equal(path)
  end

  it "rejects invalid paths" do
    lambda {Chawk.addr(@agent,['A'])}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,0)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,:a)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,Object.new)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,String.new)}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,"")}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,"/")}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,"\\")}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,"&")}.must_raise(ArgumentError)
    lambda {Chawk.addr(@agent,"?")}.must_raise(ArgumentError)
  end

  it "sets permissions" do
    @addr.must_respond_to(:set_public_read)
    @addr.must_respond_to(:set_permissions)
  end

  it "stops unauthorized access" do
    @addr.set_permissions(@agent,true,false,false)
    @addr = Chawk::Models::Node.find(@addr.id)
    lambda{Chawk.addr(@agent,'a:b')}.must_raise SecurityError
    @addr.set_permissions(@agent,false,false,false)
    lambda{Chawk.addr(@agent,'a:b')}.must_raise SecurityError
  end

  it "stops unauthorized reads" do
    @addr.set_permissions(@agent,false,false,false)
    lambda{Chawk.addr(@agent,'a:b', :write)}.must_raise SecurityError
    @addr.set_public_read true
    Chawk.addr(@agent,'a:b', :read).key.must_equal "a:b"
    @addr.set_public_read false
    lambda{Chawk.addr(@agent,'a:b', :read)}.must_raise SecurityError
    @addr.set_permissions(@agent,true,true,false)
    w_addr = Chawk.addr(@agent,'a:b', :write)
    lambda{w_addr.values_range(0,0)}.must_raise SecurityError
  end

  it "stops unauthorized writes" do
    @addr.set_permissions(@agent,true,false,false)
    lambda{Chawk.addr(@agent,'a:b', :write)}.must_raise SecurityError
    @addr.set_public_write true
    Chawk.addr(@agent,'a:b', :write).key.must_equal "a:b"
    @addr.set_public_write false
    lambda{Chawk.addr(@agent,'a:b', :write)}.must_raise SecurityError
    r_addr = Chawk.addr(@agent,'a:b', :read)
    lambda{r_addr.add_points([1,2,3,4])}.must_raise SecurityError
  end

  it "stops unauthorized admin" do
    @addr.set_permissions(@agent,false,false,false)
    lambda{Chawk.addr(@agent,'a:b', :admin)}.must_raise SecurityError
    @addr.set_permissions(@agent,false,true,true)
    Chawk.addr(@agent,'a:b', :admin).key.must_equal "a:b"
    w_addr = Chawk.addr(@agent,'a:b', :write)
    lambda{w_addr.clear_points!}.must_raise SecurityError
  end

end

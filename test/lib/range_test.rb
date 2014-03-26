require 'test_helper'

describe Chawk do
  before do
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
  end

  it "calculates range" do 
    addr1 = Chawk.addr(@agent,'a:b')
    addr2 = Chawk.addr(@agent,'a:c')
    addr3 = Chawk.addr(@agent,'a:d')
    addr1.points.destroy_all
    addr2.points.destroy_all
    addr3.points.destroy_all

    addr1._insert_point(92,1085.2340175364745)
    addr1._insert_point(94,1100.0643872093362)
    addr1._insert_point(92,1102.3558603493182)
    addr1._insert_point(94,1119.2568446818536)
    addr1._insert_point(91,1125.283357089852)
    addr1._insert_point(91,1131.9783343810343)
    addr1._insert_point(88,1132.299788479544)

    range = Chawk::Models::Range.create(start_ts:1085.0,stop_ts:1140.0,beats:1,parent_node:addr1)

    range.data_node.points.length.must_equal(220)
    range.data_node.points[25].value.must_equal(92)
    range.data_node.points[140].value.must_equal(94)
    range.data_node.points.to_a.map{|x|x.value}.reduce(:+).must_equal(20066)

    addr1.add_points [{'v'=>1500, 't'=>1135.0}] #invalidate range and rebuild

    range.reload
    range.data_node.points[200].value.must_equal(1500)
    range.data_node.points.to_a.map{|x|x.value}.reduce(:+).must_equal(48306)

    range = Chawk::Models::Range.create(start_ts:1088.0,stop_ts:8100.0,beats:14400,parent_node:addr1)
    range.data_node.points.length.must_equal(2)

    range.data_node.points.to_a.map{|x|x.value}.reduce(:+).must_equal(1592)

  end
end
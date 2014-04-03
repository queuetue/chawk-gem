require 'test_helper'

describe Chawk do
  before do
    Chawk.clear_all_data!
    @agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
  end

  it "obeys the order" do
    node1 = Chawk.node(@agent,'a:b')
    Chawk::Models::Range.new(start_ts:1140.0,stop_ts:1085.0,beats:1,parent_node:node1).save.must_equal false
    Chawk::Models::Range.new(start_ts:1140.0,stop_ts:1140.0,beats:1,parent_node:node1).save.must_equal false
    Chawk::Models::Range.new(start_ts:1000.0,stop_ts:1140.0,beats:1,parent_node:node1).save.must_equal true
  end

  it "calculates recent point" do 
    node1 = Chawk.node(@agent,'a:b')
    node1.clear_points!

    range = Chawk::Models::Range.create(start_ts:1085.0,stop_ts:1140.0,beats:1,parent_node:node1)
    ag = Chawk::Models::Aggregator.new(range.data_node)
    ag.sum.must_equal(0)
    ag.mean.round(2).must_equal(0.0)


    node1._insert_point(92,1085.2340175364745)
    node1._insert_point(94,1100.0643872093362)
    node1._insert_point(92,1102.3558603493182)
    node1._insert_point(94,1119.2568446818536)
    node1._insert_point(91,1125.283357089852)
    node1._insert_point(91,1131.9783343810343)
    node1._insert_point(88,1132.299788479544)

    range = Chawk::Models::Range.create(start_ts:1085.0,stop_ts:1140.0,beats:1,parent_node:node1)

    range.data_node.points.length.must_equal(220)
    range.data_node.points[25].value.must_equal(92)
    range.data_node.points[140].value.must_equal(94)
    ag = Chawk::Models::Aggregator.new(range.data_node)
    ag.sum.must_equal(20066)
    ag.mean.round(2).must_equal(91.21)

    node1.add_points [{'v'=>1500, 't'=>1135.0}] #invalidate range and rebuild

    range.reload
    range.data_node.points[200].value.must_equal(1500)
    ag = Chawk::Models::Aggregator.new(range.data_node)
    ag.sum.must_equal(48306)
    ag.max.must_equal(1500)
    ag.min.must_equal(0)

    range = Chawk::Models::Range.create(start_ts:1088.0,stop_ts:8100.0,beats:14400,parent_node:node1)
    range.data_node.points.length.must_equal(2)

    ag = Chawk::Models::Aggregator.new(range.data_node)
    ag.sum.must_equal(1592)
    ag.mean.must_equal(796)
    ag.stdev.round(2).must_equal(995.61)

  end

  it "calculates clusters" do
    node1 = Chawk.node(@agent,'vals')

    node1._insert_point(1,Time.parse("Nov 29, 2014 9:33:20 ").to_f)
    node1._insert_point(1,Time.parse("Nov 29, 2014 12:40:20").to_f)
    node1._insert_point(1,Time.parse("Nov 29, 2014 17:44:20").to_f)
    node1._insert_point(1,Time.parse("Nov 30, 2014 9:33:20").to_f)
    node1._insert_point(1,Time.parse("Nov 30, 2014 12:40:20").to_f)
    node1._insert_point(1,Time.parse("Dec 1, 2014 17:44:20").to_f)

    range = Chawk::Models::Range.create(start_ts:Time.parse("Nov 29, 2014 8:00:00").to_f,stop_ts:Time.parse("Dec 2, 2014 10:00:00"),beats:345600,parent_node:node1,strategy:"cluster")
    range.data_node.points.length.must_equal(4)
    range.data_node.points[0].value.must_equal(0)
    range.data_node.points[1].value.must_equal(3)
    range.data_node.points[2].value.must_equal(2)
    range.data_node.points[3].value.must_equal(1)
  end

  it "calculates tallies" do
    node1 = Chawk.node(@agent,'vals')

    node1._insert_point(1,Time.parse("Nov 29, 2014 9:33:20 ").to_f)
    node1._insert_point(1,Time.parse("Nov 29, 2014 12:40:20").to_f)
    node1._insert_point(1,Time.parse("Nov 29, 2014 17:44:20").to_f)
    node1._insert_point(1,Time.parse("Nov 30, 2014 9:33:20").to_f)
    node1._insert_point(1,Time.parse("Nov 30, 2014 12:40:20").to_f)
    node1._insert_point(1,Time.parse("Dec 1, 2014 17:44:20").to_f)

    range = Chawk::Models::Range.create(start_ts:Time.parse("Nov 29, 2014 8:00:00").to_f,stop_ts:Time.parse("Dec 2, 2014 10:00:00"),beats:345600,parent_node:node1,strategy:"tally")
    range.data_node.points.length.must_equal(4)
    range.data_node.points[0].value.must_equal(0)
    range.data_node.points[1].value.must_equal(3)
    range.data_node.points[2].value.must_equal(5)
    range.data_node.points[3].value.must_equal(6)
  end

end

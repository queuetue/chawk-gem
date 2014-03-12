require 'test_helper'

describe Chawk::Board do
	before do
		@board=Chawk::Board.new
	end

	it "has points" do
		@board.must_respond_to :points
		@board.points.wont_be_nil
	end

	it "has values" do
		@board.must_respond_to :values
		@board.values.wont_be_nil
	end
end

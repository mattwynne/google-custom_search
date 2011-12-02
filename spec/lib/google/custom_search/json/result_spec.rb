require 'spec_helper'

module Google::CustomSearch::JSON
  describe Result do
    it "returns an empty string where there is no title" do
      Result.new({}).title.should == ''
    end
  end
end

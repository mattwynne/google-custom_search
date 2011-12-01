require 'spec_helper'
require 'google/custom_search/result'

module Google::CustomSearch
  describe Result do
    it "returns an empty string where there is no title" do
      Result.new({}).title.should == ''
    end
  end
end

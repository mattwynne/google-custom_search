require 'spec_helper'

module Google
  describe CustomSearch do
    let(:config) do
      stub \
        :cref => 'https://github.com/mattwynne/google-custom_search/blob/master/spec/fixtures/mcht-only.xml',
        :key => 'AIzaSyA-AayUZh6S5mGMmja3pt2gfpsncLiwqN8',
        :service_type => CustomSearch::JSON::Service
    end

    def search_for(query_string, options = {})
      start_index = options[:start_index] || 1
      query = CustomSearch::Query.new(query_string, start_index, config)
      query.results
    end
    
    describe "retry on error" do

      context "when Google returns a 400 bad request error" do

        before(:each) do
          stub_request(:any, /.*/).to_return(
            :status => [400, "Bad Request"],
            :body => "A helpful message"
          )
        end

        it "raises an error" do
          expect { search_for 'foo' }.to raise_error(CustomSearch::BadRequestError)
        end

        it "returns the body of the response in the error message" do
          begin
            search_for 'foo'
          rescue => error
            error.to_s.should =~ /A helpful message/
          end
        end

      end

      context "when Google returns a 500 bad request error for the first four requests but subsequent requests are OK" do

        before(:each) do
          stub_request(:any, /.*/).to_return(
            { :status => [500, "Bad Request"] },
            { :status => [500, "Bad Request"] },
            { :status => [500, "Bad Request"] },
            { :status => [500, "Bad Request"] },
            { :status => [200, "OK"], :body => '[]' }
          )
        end

        it "does not raise an error" do
          expect { search_for 'foo' }.to_not raise_error(CustomSearch::BadRequestError)
        end

      end
    end
    
    { 
      :json => {
        :service_type => CustomSearch::JSON::Service,
        :cref => 'http://sure-search.heroku.com/test/mcht-only.xml',
        :key => 'AIzaSyA-AayUZh6S5mGMmja3pt2gfpsncLiwqN8' 
      },
      :xml => {
        :service_type => CustomSearch::XML::Service,
        :cx => '003087164461061609361:-u1ua6laowa'
      }
    }.each do |service, config|

      context "using the #{service} service" do
        let(:config) { stub config }
        before { config.stub(:service => service) }
        
        context "searching for something that exists in the list" do
          let(:results) { search_for 'kath morgan' }

          it "returns exactly 1 result" do
            results.length.should == 1
          end

          it "returns the expected result" do
            results.first.content.should =~ /01270 275215/
            # that's Kath's phone number
          end

          it 'returns the expected site' do
            results.first.site.should == 'www.mcht.nhs.uk'
          end

        end

        context "searching for something that doesn't exist" do
          let(:results) { search_for 'eee' }

          it "returns no results" do
            results.should be_empty
          end
        end
        
        describe "#next_page" do
        
          context "a search that returns multiple pages of results" do
            let(:results) { search_for 'trust' }
        
            it "has a start_index of 11" do
              results.next_page.start_index.should == 11
            end
          end
        
          context "a search for the second of multiple pages" do
            let(:results) { search_for 'trust', :start_index => 11 }
        
            it "has a start_index of 21" do
              results.next_page.start_index.should == 21
            end
          end
        
          context "a search that returns one page of results" do
            let(:results) { search_for 'kath morgan' }
        
            it "returns 1, pointing you back to the same page of results" do
              results.next_page.start_index.should == 1
            end
        
            it "is equal to the #current_page" do
              results.next_page.should == results.current_page
            end
          end
        end

        describe "#current_page" do
          context "a search for the second of multiple pages" do
            let(:results) { search_for 'trust', :start_index => 11 }
        
            it "has a start_index of 11" do
              results.current_page.start_index.should == 11
            end
        
            it "converts to a summary string" do
              results.current_page.to_s.should =~ /results 11-20 of \d+/
            end
          end
        end
        
        describe "#previous_page" do
          context "a search for the second of multiple pages" do
            let(:results) { search_for 'trust', :start_index => 11 }
        
            it "has a start_index of 1" do
              results.previous_page.start_index.should == 1
            end
        
          end
        end
        
      end
    end
  end
end

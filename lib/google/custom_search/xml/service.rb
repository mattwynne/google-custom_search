require 'google/custom_search/xml/results'

module Google
  module CustomSearch
    module XML

      class Service

        def initialize(config)
          @config = config
          @resource = RestClient::Resource.new('http://www.google.com/cse')
        end

        def request(query_string, start_index)
          @resource.get(:params => params(query_string, start_index)) do |response, request, result|
            unless response.code == 200
              raise BadRequestError, "Unable to fetch results from Google: #{response}"
            end
            Results.new(response)
          end
        end

      private

        def params(query_string, start_index)
          {
            :q => query_string,
            :output => 'xml_no_dtd',
            :start => start_index - 1,
            :cx => @config.cx,
          }
        end

      end
      
    end
  end
end
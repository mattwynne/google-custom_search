require 'google/custom_search/json/results'

module Google
  module CustomSearch
    module JSON

      class Service

        def initialize(config)
          @config = config
          @resource = RestClient::Resource.new('https://www.googleapis.com/customsearch/v1')
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
            :start => start_index,
            :key  => @config.key,
            :cref => @config.cref,
          }
        end

      end
      
    end
  end
end
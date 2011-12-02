require 'google/custom_search/config'
require 'google/custom_search/json/service'
require 'google/custom_search/xml/service'

module Google
  module CustomSearch

    class BadRequestError < StandardError
    end

    class ConfigurationError < StandardError
    end

    class Query

      def initialize(query_string, start_index, config = Google::CustomSearch.config)
        @query_string = query_string
        @start_index = start_index
        @service = config.service_type.new(config)
      end

      def results
        attempts = 5
        begin
          @service.request(@query_string, @start_index)
        rescue BadRequestError
          attempts -= 1
          retry if attempts > 0
          raise
        end
      end
      
    end
  end
end

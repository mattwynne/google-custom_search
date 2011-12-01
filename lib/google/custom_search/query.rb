require 'google/custom_search/config'
require 'google/custom_search/result'

module Google
  module CustomSearch

    class BadRequestError < StandardError
    end

    class Query

      def initialize(query_string, start_index)
        @query_string = query_string
        @start_index = start_index
        @service = Service.new(Google::CustomSearch.config)
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
            :cref => @config.annotations_url,
          }
        end

      end

      class Results
        include Enumerable

        def initialize(response)
          @data = JSON.parse(response)
        end

        def each(&block)
          items.each(&block)
        end

        def empty?
          items.empty?
        end

        def length
          items.length
        end

        def next_page
          Page.new(@data['queries']['nextPage'] || @data['queries']['request'])
        end

        def current_page
          Page.new(@data['queries']['request'])
        end

        def previous_page
          Page.new(@data['queries']['previousPage'] || @data['queries']['request'])
        end

      private

        def items
          @items ||= (@data['items'] || []).map do |item|
            Result.new(item)
          end
        end

        class Page
          def initialize(data)
            @data = data[0]
          end

          def start_index
            @data['startIndex']
          end

          def to_s
            "results #{start_index}-#{end_index} of #{total}"
          end

          def ==(other)
            other.start_index == start_index
          end

        private

          def total
            @data['totalResults']
          end

          def end_index
            start_index + @data['count'] - 1
          end
        end

      end
    end
  end
end

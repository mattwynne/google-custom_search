require 'json'

module Google
  module CustomSearch
    
    module JSON
      
      class Results
        include Enumerable

        def initialize(response)
          @data = ::JSON.parse(response)
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
      
      class Result
        def initialize(data)
          @data = data
        end
    
        def title
          @data['title'] || ''
        end
    
        def uri
          @data['link']
        end
    
        def content
          @data['htmlSnippet']
        end

        def site
          @data['displayLink']
        end
      end
      
    end
    
  end
end

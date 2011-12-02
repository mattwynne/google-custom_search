require 'json'
require 'nokogiri'

module Google
  module CustomSearch
    
    module XML
      
      class Results
        include Enumerable

        def initialize(response)
          @doc = Nokogiri::XML.parse(response)
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
          return current_page unless @doc.search('//RES/NB').any?
          Page.new(current_page.end_index + 1, current_page.end_index + 11, 10)
        end

        def current_page
          Page.from_xml(@doc.search('//RES').first)
        end

        def previous_page
          return current_page if current_page.start_index == 1
          Page.new(current_page.start_index - 10, current_page.start_index, 10)
        end

      private

        def items
          @items ||= @doc.search('//RES/R').map do |node|
            Result.new(node)
          end
        end
        
        class Page < Struct.new(:start_index, :end_index, :total)
          def self.from_xml(node)
            new(
              node.attributes['SN'].text.to_i,
              node.attributes['EN'].text.to_i,
              node.search('M').text.to_i)
          end
          
          def to_s
            "results #{start_index}-#{end_index} of #{total}"
          end
        
          def ==(other)
            other.start_index == start_index
          end
        
        end

      end
      
      class Result
        def initialize(node)
          @node = node
        end
    
        def title
          @node.search('T').text
        end
    
        def uri
          @node.search('U').text
        end
    
        def content
          @node.search('S').text
        end

        def site
          URI.parse(@node.search('U').text).host
        end
      end
      
    end
    
  end
end

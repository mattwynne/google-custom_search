module Google
  module CustomSearch
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

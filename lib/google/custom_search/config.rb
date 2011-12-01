module Google
  module CustomSearch
    class Config
      attr_accessor :path
      attr_accessor :environment
      attr_writer   :annotations_url
      attr_writer   :cse_id

      def key
        read('api_key')
      end

      def cse_id
        @cse_id || read('cse_id')
      end
    
      def annotations_url
        @annotations_url || read('annotations_url')
      end
    
    private
  
      def read(key)
        env_config[key] || raise("Key '#{key}' was not found in your config file #{path}. Alternatives: #{env_config.keys.join(',')}")
      end
      
      def env_config
        all_config[environment] || raise("No key for environment '#{environment}' found in #{path}")
      end
  
      def all_config
        return @config if @config
        [:path, :environment].each do |param|
          raise "Please set Google::CustomSearch.config.#{param}" unless self.send(param)
        end

        raise "Config file does not exist at #{path}" unless File.exists?(path)
        @config = YAML.load_file(path)
      end
    end
  
    class << self
      attr_accessor :config

      def configure
        yield config
      end
      
    end
    
    self.config = Config.new
  end
end

if defined?(Rails)
  Google::CustomSearch.configure do |config|
    config.path = "#{Rails.root}/config/google.yml"
    config.environment = Rails.env
  end
end

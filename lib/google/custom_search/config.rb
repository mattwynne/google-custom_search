module Google
  module CustomSearch
    class Config
      attr_accessor :path
      attr_accessor :environment
      
      [:key, :cx, :cse_id, :cref, :service].each do |key|
        attr_writer key
        define_method(key) do
          instance_variable_get("@#{key}".to_sym) || read(key)
        end
      end
      
      def service_type
        eval("#{self.service.upcase}::Service")
      end
    
    private
  
      def read(key)
        env_config[key.to_s] || raise("Key '#{key}' was not found in your config file #{path}. Alternatives: #{env_config.keys.join(',')}")
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

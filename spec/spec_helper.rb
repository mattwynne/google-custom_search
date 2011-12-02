RSpec.configure do |config|
  config.mock_with :rspec
end

require 'webmock/rspec'
WebMock.allow_net_connect!

require 'google/custom_search'
Google::CustomSearch.configure do |config|
  config.path = File.dirname(__FILE__) + '/fixtures/config/google.yml'
  config.environment = 'test'
end

spec = Gem::Specification.new do |s|
  s.name = 'google-custom_search'
  s.version = '0.0.4'
  s.summary = "Interface for Google's Custom Search APIs"
  s.description = %{Ruby library for querying Google's Custom Search APIs.}
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  s.require_path = 'lib'
  s.has_rdoc = false
  s.author = "Matt Wynne"
  s.email = "matt@mattwynne.net"
  s.homepage = "https://github.com/mattwynne/google-custom_search"

  s.add_dependency 'rest-client', '~> 1.6'
  s.add_dependency 'nokogiri', '~> 1.5'

  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'webmock', '~> 1.7'
  s.add_development_dependency 'guard-rspec'
end

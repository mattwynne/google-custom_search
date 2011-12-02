# Google Custom Search

This gem gives you a Ruby interface onto Google's Custom Search APIs.

There are two APIs, an old XML one and a new JSON one. At the time of writing, the JSON one is not 
stable, so this gem aims to act as an adapter layer allowing you to call either service with the same
code.

## Usage

With the gem installed, make a query like this:

    results = Google::CustomSearch::Query.new('my query').results

The results object is `Enumerable`. See the code for details.

## Configuration

This is the tricky part. The basic structure for a config file is to have one top-level key per environment (development, test, production etc.) Within that environment key, you need a `service` key set to either `json` or `xml`. The rest of the keys you need very depending on whether you're using JSON or XML.

For the XML service, you just need a `cx` key which you can get from your control panel. That assumes you'll configure your annotations yourself.

For the JSON service, you'll need a valid API key in `key`. Assuming you're hosting your own annotations, you need a `cref` key pointing to the URL where google can find your annotations file. You'll find an example [here](https://raw.github.com/mattwynne/google-custom_search/master/spec/fixtures/json_api_annotations.xml).

### Rails apps

Put something like this into `config/google.yml`

    production:
      service: xml
      cx: 003087164461061609361:abcdefg1h2i

### Non-Rails apps

You'll need to tell the library where to find your config file. Do that like this:

    require 'google/custom_search'
    Google::CustomSearch.configure do |config|
      config.path = File.dirname(__FILE__) + '/../config/google.yml'
      config.environment = ENV['RACK_ENV']
    end

# Bugs, Patches etc

I built this library for a client project and don't intend to maintain it. Please don't submit bug reports and expect me to fix them. 

Patches, however, are most welcome as long as they come with a spec.

require File.expand_path("../lib/rack/prettify/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-prettify"
  s.version     = Rack::Prettify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["logicaltext"]
  s.email       = ["logicaltext@logicaltext.com"]
  s.homepage    = "http://github.com/logicaltext/rack-prettify"
  s.summary     = "Rack middleware for prettifying markup"
  s.description = "Rack middleware for prettifying markup, " \
                  "useful in conjunction with upstream middleware " \
                  "that regurgitates (X)HTML."\

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "rack-prettify"

  s.add_dependency "rack"
  s.add_dependency "nokogiri", ">= 1.4.2"

  s.files        = Dir.glob("lib/**/*") + Dir["LICENSE", "*.md"]
  s.require_path = 'lib'
end

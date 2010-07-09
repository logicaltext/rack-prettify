require "bundler"
Bundler.setup

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

gemspec = eval(File.read("rack-prettify.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["rack-prettify.gemspec"] do
  system "gem build rack-prettify.gemspec"
  system "gem install rack-prettify-#{Rack::Prettify::VERSION}.gem"
end

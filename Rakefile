$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'bundler/gem_tasks'
require 'visionbundles/version'

task :build do
  system "gem build visionbundles.gemspec"
end

task :release => :build do
  system "gem push visionbundles-#{Visionbundles::VERSION}.gem"
end

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'bundler/gem_tasks'
require 'visionbundles/version'

task :build do
  system "gem build visionbundles.gemspec"
end

task :release => :build do
  gem_name = "visionbundles-#{Visionbundles::VERSION}.gem"
  system "gem push #{gem_name}"
  system "rm -rf #{gem_name}"
end

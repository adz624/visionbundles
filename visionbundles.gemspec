# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "visionbundles/version"

Gem::Specification.new do |s|
  s.name        = "visionbundles"
  s.version     = Visionbundles::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = %q{common deploy flow tasks for capistrano 2.x.x}
  s.description = %q{nginx, puma, sidekiq, deploy flow}

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.authors     = ["Eddie Li"]
  s.email       = ["eddie@visionbundles.com"]
  s.homepage    = "https://github.com/afunction/visionbundles"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.license          = 'MIT'

  s.add_dependency 'asset_sync', '~> 1.1.0'
  s.add_dependency 'fog', '~> 1.23.0'
  s.add_dependency 'colorize', '~> 0'
end
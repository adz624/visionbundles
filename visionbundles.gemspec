# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "visionbundles/version"

Gem::Specification.new do |s|
  s.name        = "visionbundles"
  s.version     = Visionbundles::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = %q{Deploy recipes for capistrano 2.15.5}
  s.description = %q{In this gem, there's some deploy recipes includes: nginx, puma, db, secret, fast_assets, and it also provide cdn, compile assets locally function}

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
  s.add_dependency 'net-ssh-simple', '~> 1.6.6'
end
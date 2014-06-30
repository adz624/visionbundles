# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "visionbundles/version"

Gem::Specification.new do |s|
  s.name        = "visionbundles"
  s.version     = Visionbundles::VERSION
  s.authors     = ["Eddie Li"]
  s.email       = ["eddie@visionbundles.com"]
  s.homepage    = "https://github.com/afunction/visionbundles"
  s.summary     = %q{cap/rake task gem}
  s.description = %q{cap/rake task gem}

  s.rubyforge_project = "visionbundles"

  s.add_dependency 'colorize'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

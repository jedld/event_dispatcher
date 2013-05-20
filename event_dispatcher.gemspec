# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "event_dispatcher/version"

Gem::Specification.new do |s|
  s.name        = "event_dispatcher"
  s.version     = EventDispatcher::VERSION
  s.authors     = ["Joseph Emmanuel Dayo"]
  s.email       = ["jdayo@friendster.com"]
  s.homepage    = ""
  s.summary     = %q{Event Driven Framework for Rails}
  s.description = %q{Event Driven Framework for Rails}

  s.rubyforge_project = "event_dispatcher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

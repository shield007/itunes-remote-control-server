$:.push File.expand_path("../lib", __FILE__)
require 'itunesController/version'

Gem::Specification.new do |s|
  s.name        = 'itunes-controller'
  s.version     = ItunesController::VERSION
  s.date        = '2012-02-06'
  s.summary     = "TCP command server that can be used to control iTunes headlessly"
  s.description = "A application to control enable iTunes to be operated on a headless server without the GUI. It provides a TCP server which can be connected to locally or remote by other applications to control iTunes"
  s.authors     = ["John-Paul Stanford"]
  s.email       = 'dev@stanwood.org.uk'
  s.homepage    = 'http://code.google.com/p/itunes-remote-control-server/'
  s.files       = `git ls-files`.split("\n")  
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

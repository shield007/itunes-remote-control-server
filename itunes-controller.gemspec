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
  s.has_rdoc     = 'yard'
  s.rdoc_options = [ '--main', 'README' ] 
  s.extra_rdoc_files = [ 'LICENSE', 'README' ] 
  s.add_development_dependency('yard')
  s.add_development_dependency('rake')
  s.add_development_dependency('test-unit')
  s.add_dependency('escape')
  s.add_dependency('sqlite3')
  s.add_dependency('etc')  
end

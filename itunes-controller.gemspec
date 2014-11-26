$:.push File.expand_path("../lib", __FILE__)
require 'itunesController/version'

Gem::Specification.new do |s|
  s.name        = 'itunes-controller'
  s.version     = ItunesController::VERSION
  s.date        = '2014-11-26'
  s.summary     = "TCP command server that can be used to control iTunes headlessly"
  s.description = "A application to control enable iTunes to be operated on a headless server without the GUI. It provides a TCP server which can be connected to locally or remote by other applications to control iTunes"
  s.authors     = ["John-Paul Stanford"]
  s.email       = 'dev@stanwood.org.uk'
  s.homepage    = 'https://github.com/shield007/itunes-remote-control-server'
  s.files       = `git ls-files`.split("\n")  
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.has_rdoc     = 'yard'
  s.rdoc_options = [ '--main', 'Readme.md' ] 
  s.extra_rdoc_files = [ 'LICENSE', 'Readme.md' ] 
  s.add_development_dependency('yard')
  s.add_development_dependency('rake')
  s.add_development_dependency('test-unit')
  s.add_dependency('escape')
  s.add_dependency('sqlite3') if RUBY_PLATFORM != 'java'
  s.add_dependency('log4r')
  s.add_dependency('json')
  s.add_dependency('sequel')  
end

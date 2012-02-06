Gem::Specification.new do |s|
  s.name        = 'itunes-controller'
  s.version     = '0.1.0'
  s.date        = '2012-02-06'
  s.summary     = "TCP command server that can be used to control iTunes headlessly"
  s.description = "A application to control enable iTunes to be operated on a headless server without the GUI. It provides a TCP server which can be connected to locally or remote by other applications to control iTunes"
  s.authors     = ["John-Paul Stanford"]
  s.email       = 'dev@stanwood.org.uk'
  s.files       = ["README","LICENSE",
                   "bin/dummyiTunesController.rb",
                   "bin/itunesController.rb",
                   "bin/listDeadTracks.rb",
                   "bin/listNewTracks.rb",
                   "bin/removeDeadTracks.rb",
                   "lib/itunesController/config.rb",
                   "lib/itunesController/controllserver.rb",
                   "lib/itunesController/debug.rb",
                   "lib/itunesController/dummy_itunescontroller.rb",
                   "lib/itunesController/itunescontroller.rb",
                   "lib/itunesController/kinds.rb",
                   "lib/itunesController/macosx_itunescontroller.rb"]
  s.homepage    = 'http://code.google.com/p/itunes-remote-control-server/'
  s.executables = ["dummyiTunesController.rb",
                   "itunesController.rb",
                   "listDeadTracks.rb",
                   "listNewTracks.rb",
                   "removeDeadTracks.rb"]
  s.require_paths = ["lib"]
end

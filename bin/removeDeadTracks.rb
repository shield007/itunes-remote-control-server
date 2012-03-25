#!/usr/bin/ruby -I../liby
#
# A command line util used to remove tracks from iTunes whoes files can't be found.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/itunescontroller_factory'
require 'itunesController/version'

require 'rubygems'
require 'fileutils'

controller = ItunesController::ITunesControllerFactory::createController()

deadTracks=controller.findDeadTracks

deadTracks.each do | deadTrack | 
    if (deadTrack.show!=nil && deadTrack.show!="")
        puts "TV: "+deadTrack.show+" - " + deadTrack.name
    else
        puts "Film: "+deadTrack.name
    end
end

controller.removeTracksFromLibrary(deadTracks)

puts "Done"

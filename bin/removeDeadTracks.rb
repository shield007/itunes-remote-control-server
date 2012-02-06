#!/usr/bin/ruby -I ../lib/ruby
#
# This is a problem to scan a list of media directiores for files that are not
# in a itunes library.
#
# This application has been written for macosx's version of ruby, so it must
# be run using the mac ruby interpter.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/macosx_itunescontroller'

require 'rubygems'
require 'fileutils'

controller = MacOSXITunesController.new

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

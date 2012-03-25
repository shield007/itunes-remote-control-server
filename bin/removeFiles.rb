#!/usr/bin/ruby -I../lib
#
# A command line util used to remove tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/itunescontroller_factory'

require 'rubygems'

if ARGV.length == 0
    puts "usage: removeFiles.rb files..."
    exit
end

controller = ItunesController::ITunesControllerFactory::createController()
tracks=controller.findTracksWithLocations(ARGV)
controller.removeTracksFromLibrary(tracks)

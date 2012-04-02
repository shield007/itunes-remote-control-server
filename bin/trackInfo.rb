#!/usr/bin/ruby -I../lib
#
# A command line util used to remove tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/cachedcontroller'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/application'

class App < ItunesController::Application

    # Used to display the command line useage
    def displayUsage()
        puts("Usage: "+@appName+" [options] files...")
        puts("")
        puts(genericOptionDescription())
    end

    def checkAppOptions()
        if ARGV.length == 0
            usageError("No files given.")
        end
    end

    def execApp(controller)
        ARGV.each do | path |
            track=controller.getTrack(path)
            if (track!=nil)
                ItunesController::ItunesControllerDebug::printTrack(track) 
            else
                ItunesController::ItunesControllerLogging::error("Unable to find track")
            end
            ItunesController::ItunesControllerLogging::info("")
        end
    end
end

app=App.new("trackInfo.rb")
app.exec()
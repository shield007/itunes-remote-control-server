#!/usr/bin/ruby -I../lib
#
# A command line util used to remove tracks from iTunes whoes files can't be found.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/cachedcontroller'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/application'

class AddFilesApp < ItunesController::Application

    # Used to display the command line useage
    def displayUsage()
        puts("Usage: "+@appName+" [options]")
        puts("")
        puts("Specific options:")
        puts("    -l, --log FILE                   Optional paramter used to log messages to")
        puts("    -h, --help                       Display this screen")
    end

    def checkAppOptions()
    end

    def execApp(controller)
        count=controller.removeDeadTracks()
        ItunesController::ItunesControllerLogging::info("Removed #{count} dead tracks")
    end
end

app=AddFilesApp.new("removeDeadTracks.rb")
app.exec()


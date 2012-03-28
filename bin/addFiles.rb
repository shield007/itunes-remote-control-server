#!/usr/bin/ruby -I../lib
#
# A command line util used to add tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/cachedcontroller'
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
        usageError("No config file specified. Use --config option.")
    end

    def execApp(controller)
        ARGV.each do | path |
            controller.addTrack(path)
        end
    end
end

app=AddFilesApp.new("addFiles.rb")
app.exec()

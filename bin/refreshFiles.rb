#!/usr/bin/ruby -I../lib
#
# A command line util used to remove tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'itunesController/application'
require 'itunesController/sqlite_creator'

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

    def createController
        return ItunesController::SQLLiteControllerCreator.new
    end
    
    def execApp(controllerCreator)
        controller = controllerCreator.createController()
        ARGV.each do | path |
            controller.updateTrack(path)
        end
    end
end

if $0 == __FILE__
    app=App.new("refreshTracks.rb")
    app.exec()
end
                               

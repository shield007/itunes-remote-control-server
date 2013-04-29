#!/usr/bin/ruby -I../lib
#
# A command line util used to list tracks in the iTunes library when their files can't be found.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'itunesController/cachedcontroller'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/application'
require 'itunesController/sqlite_creator'

class App < ItunesController::Application

    def createController
            return ItunesController::SQLLiteControllerCreator.new
        end
    
    def execApp(controllerCreator)
        controller = controllerCreator.createController()
        deadTracks=controller.findDeadTracks
        count=0
        deadTracks.each do | deadTrack | 
            result=[]
            result.push("Name: "+deadTrack.title)
            result.push("Database ID: "+deadTrack.databaseId.to_s)
            if (deadTrack.location==nil)
                result.push("Location: Unknown")
            else
                result.push("Location: "+deadTrack.location)
            end
            ItunesController::ItunesControllerLogging::info(result.join("\n"))
            ItunesController::ItunesControllerLogging::info("")
            count+=1
        end
        ItunesController::ItunesControllerLogging::info("Found #{count} dead tracks")
    end
end

if __FILE__.end_with?(Pathname.new($0).basename)
    app=App.new("listDeadTracks.rb")
    app.exec()
end


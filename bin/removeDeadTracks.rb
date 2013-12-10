#!/usr/bin/ruby -I../lib
#
# A command line util used to remove tracks from iTunes whoes files can't be found.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'itunesController/cachedcontroller'
require 'itunesController/sqlite_creator'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/application'

class App < ItunesController::Application

    def createController
        return ItunesController::SQLLiteControllerCreator.new
    end
    
    def execApp(controllerCreator)
        controller = controllerCreator.createController()
        count=controller.removeDeadTracks()
        ItunesController::ItunesControllerLogging::info("Removed #{count} dead tracks")
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    app=App.new("removeDeadTracks.rb")
    app.exec()
end


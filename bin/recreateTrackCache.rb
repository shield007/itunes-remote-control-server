#!/usr/bin/ruby -I../lib
#
# A command line util used to remove tracks to the iTunes library
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
        if (!controller.getCachedTracksOnCreate())
            controller.cacheTracks(true)
        end
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    app=App.new("regenerateTrackCache.rb")
    app.exec()
end

#!/usr/bin/ruby -I../lib
#
# A command line util used to add tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'itunesController/cachedcontroller'
require 'itunesController/application'
require 'itunesController/sqlite_creator'

class App < ItunesController::Application

    def displayUsage()
        puts("Usage: "+@appName+" [options] files...") 
        puts("")
        puts(genericOptionDescription())
    end
    
    def createController
        return ItunesController::SQLLiteControllerCreator.new
    end

    def execApp(controllerCreator)
        controller = controllerCreator.createController()
        ARGV.each do | path |
            controller.addTrack(path)
        end
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    app=App.new("addFiles.rb")
    app.exec()
end

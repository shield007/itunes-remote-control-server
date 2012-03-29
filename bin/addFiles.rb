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

class App < ItunesController::Application

    def displayUsage()
        puts("Usage: "+@appName+" [options] files...") 
        puts("")
        puts(genericOptionDescription())
    end

    def execApp(controller)
        ARGV.each do | path |
            controller.addTrack(path)
        end
    end
end

app=App.new("addFiles.rb")
app.exec()

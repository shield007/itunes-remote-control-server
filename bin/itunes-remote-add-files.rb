#!/usr/bin/ruby -I../lib
#
# A command line util used to add tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/remote_application'

class App < ItunesController::RemoteApplication   
    
    def displayUsage()
        puts("Usage: "+@appName+" [options] files...") 
        puts("")
        puts(genericOptionDescription())
    end
    
    def execApp()                       
        ARGV.each do | path |
            file(path)                       
        end
        addFiles()
    end
end

app=App.new("itunes-remote-add-files.rb")
app.exec()

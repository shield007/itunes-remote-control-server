#!/usr/bin/ruby -I../lib
#
# A command line util used to add tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'itunesController/remote_application'

class AppListTracks < ItunesController::RemoteApplication   
    
    def displayUsage()
        puts("Usage: "+@appName+" [options]") 
        puts("")
        puts(genericOptionDescription())
    end
    
    def execApp(args)
        listTracks()                               
    end
end

if $0 == __FILE__
    args = ARGV
    app=AppListTracks.new("itunes-remote-list-tracks.rb")
    app.exec(args)
end

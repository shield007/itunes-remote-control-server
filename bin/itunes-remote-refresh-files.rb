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

class AppRefreshFiles < ItunesController::RemoteApplication   
    
    def displayUsage()
        puts("Usage: "+@appName+" [options] files...") 
        puts("")
        puts(genericOptionDescription())
    end
    
    def execApp(args)
        if (args.length()==0)
            ItunesController::ItunesControllerLogging::error("No files given on the command line to refresh in iTunes")
        else
            args.each do | path |
                file(path)                       
            end
            refreshFiles()
        end                               
    end
end

if $0 == __FILE__
    args = ARGV
    app=AppRefreshFiles.new("itunes-remote-refresh-files.rb")
    app.exec(args)
end
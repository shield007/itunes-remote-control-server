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
require 'itunesController/remote_application'

class AppServerInfo < ItunesController::RemoteApplication   
    
    # Display the command line usage of the application
    def displayUsage()
        puts("Usage: "+@appName+" [options]") 
        puts("")
        puts(genericOptionDescription())
    end
    
    # Used to get information about the server and print it to stdout
    def serverInfo()
        result=sendCommand(ItunesController::CommandName::VERSION,ItunesController::Code::OK.to_i)
        result = JSON.parse(result)           
        @stdout.puts("ITunes control server : #{result['server']}")
        @stdout.puts("Apple iTunes version : #{result['iTunes']}")
        result=sendCommand(ItunesController::CommandName::SERVERINFO,ItunesController::Code::OK.to_i)
        result = JSON.parse(result)
        @stdout.puts("Cache Dirty: #{result['cacheDirty']}")
        @stdout.puts("Cached Track Count: #{result['cachedTrackCount']}")
        @stdout.puts("Cached Dead Track Count: #{result['cachedDeadTrackCount']}")
        @stdout.puts("Cached Library Track Count: #{result['cachedLibraryTrackCount']}")
        @stdout.puts("Library Track Count: #{result['libraryTrackCount']}")
    end       
    
    # Called when the application is executed to retrieve the server information
    # @param args The arguments passed to the application
    def execApp(args)
        serverInfo()                               
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=AppServerInfo.new("itunes-remote-server-info.rb")
    app.exec(args)
end

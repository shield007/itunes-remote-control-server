#!/usr/bin/ruby -I../lib
#
# A command line util used to list dead tracks found by the server
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'itunesController/remote_application'

class AppListTracks < ItunesController::RemoteApplication   

    # Display the command line usage of the application    
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options]") 
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())
    end
    
    # Called to send the commands to the server that will list dead tracks found by the server.
    # The tracks are printed to stdout
    def listDeadTracks()
        result=sendCommand(ItunesController::CommandName::LISTDEADTRACKS,ItunesController::Code::OK.to_i)
        result = JSON.parse(result)
        tracks = result['tracks']
        if (tracks==nil or tracks.length()==0)
            @stdout.puts("No tracks found")
        else
            tracks.each do | track |
                @stdout.puts("Title: #{track['title']} - DatabaseId: #{track['databaseId']}")
            end
            
        end
    end
    
    # Call the server to list dead tracks
    # @param args The arguments passed to the application
    def execApp(args)
        listDeadTracks()                               
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=AppListTracks.new("itunes-remote-list-dead-tracks.rb")
    app.exec(args)
end

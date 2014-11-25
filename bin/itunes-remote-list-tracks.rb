#!/usr/bin/ruby -I../lib
#
# A command line util used to list tracks found by the server
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

this_dir = File.dirname(__FILE__)            
lib_dir  = File.join(this_dir,  '..', 'lib')
$: << lib_dir

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
    
    # Called to send the commands to the server that will list tracks found by the server.
    # The tracks are printed to stdout
    def listTracks()
        result=sendCommand(ItunesController::CommandName::LISTTRACKS,ItunesController::Code::OK.to_i)
        result = JSON.parse(result)
        tracks = result['tracks']
        if (tracks==nil or tracks.length()==0)
            @stdout.puts("No tracks found")
        else
            tracks.each do | track |
                @stdout.puts("Location: #{track['location']} - Title: #{track['title']} - DatabaseId: #{track['databaseId']}")
            end            
        end            
    end
    
    # Call the server to list tracks
    # @param args The arguments passed to the application
    def execApp(args)
        listTracks()                               
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=AppListTracks.new("itunes-remote-list-tracks.rb")
    app.exec(args)
end

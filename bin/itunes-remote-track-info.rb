#!/usr/bin/ruby -I../lib
#
# A command line utility to display track information
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'itunesController/remote_application'

class TrackInfoListTracks < ItunesController::RemoteApplication   
    
    # Display the command line usage of the application
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options] files...") 
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())
    end

    # Print track information to stdout
    # @param path The location of the track to print information for     
    def infoTrackByPath(path)
        result=sendCommand(ItunesController::CommandName::TRACKINFO+':path:'+path,ItunesController::Code::OK.to_i)            
        result = JSON.parse(result)      
        result.each do | k,v |
            @stdout.puts("#{k}: #{v}")
        end      
    end
    
    # Called when the application is executed to display track information
    # @param args The arguments passed to the application
    def execApp(args)        
        if (args.length()==0)
            ItunesController::ItunesControllerLogging::error("No files given on the command line")
        else
            args.each do | path |
                puts "Path: #{path}"
                infoTrackByPath(path)                       
            end            
        end                                          
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=TrackInfoListTracks.new("itunes-remote-track-info.rb")
    app.exec(args)
end

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
require 'json'

class TrackInfoListTracks < ItunesController::RemoteApplication   
    
    # Display the command line usage of the application
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options] files...") 
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())
        @stdout.puts("    -j, --json                       If this option is given, output will be in JSON format")
    end
    
    # Parse the options for this application
    # @param opts The OptionParser
    def parseAppOptions(opts)
        opts.on('-j','--json','If this option is given, output will be in JSON format') do
            @options[:json] = true;
        end        
    end    

    # Print track information to stdout
    # @param path The location of the track to print information for        
    def infoTrackByPathText(path)
        result = getTrackInfo(path)        
        result.each do | k,v |
            @stdout.puts("#{k}: #{v}")
        end        
        @stdout.puts("\n")
    end
    
    # Get the information about a track
    # @param path The location of the track to print information for
    # @return Hash with the track info
    def getTrackInfo(path)
        result=sendCommand(ItunesController::CommandName::TRACKINFO+':path:'+path,ItunesController::Code::OK.to_i)                    
        result = JSON.parse(result)
        return result
    end
    
    # Called when the application is executed to display track information
    # @param args The arguments passed to the application
    def execApp(args)        
        if (args.length()==0)
            ItunesController::ItunesControllerLogging::error("No files given on the command line")
        else
            json = false
            if @options[:json]==true
                json=true
            end
            if json
                result = []
                args.each do | path |
                    result << getTrackInfo(path)
                end
                @stdout.puts(JSON.pretty_generate(result))
            else
                args.each do | path |                
                    infoTrackByPathText(path)                       
                end    
            end        
        end                                          
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=TrackInfoListTracks.new("itunes-remote-track-info.rb")
    app.exec(args)
end

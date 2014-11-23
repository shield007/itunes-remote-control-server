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
require 'json'

class AppServerInfo < ItunesController::RemoteApplication   
    
    KEY_NAMES = {
        'server' => 'ITunes control server',
        'iTunes' => 'Apple iTunes version',
        'cacheDirty' => 'Cache Dirty',
        'cachedTrackCount' => 'Cached Track Count',
        'cachedDeadTrackCount' => 'Cached Dead Track Count',
        'cachedLibraryTrackCount' => 'Cached Library Track Count',
        'libraryTrackCount' => 'Library Track Count'
    }
    
    # Display the command line usage of the application
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options]") 
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
    
    # Used to get information about the server and print it to stdout
    def serverInfo(json)
        tmp=sendCommand(ItunesController::CommandName::VERSION,ItunesController::Code::OK.to_i)
        versionResult = JSON.parse(tmp)
        tmp=sendCommand(ItunesController::CommandName::SERVERINFO,ItunesController::Code::OK.to_i)
        cacheResult= JSON.parse(tmp)
        commandResult = versionResult.merge(cacheResult)
        if json
            result = {}            
            KEY_NAMES.each do | key,value | 
                result[value]=commandResult[key]
            end
            @stdout.puts(JSON.pretty_generate(result))
        else                           
            KEY_NAMES.each do | key,value |                
                @stdout.puts("#{value}: #{commandResult[key]}")
            end            
        end 
    end       
    
    # Called when the application is executed to retrieve the server information
    # @param args The arguments passed to the application
    def execApp(args)
        json = false
        if @options[:json]==true
            json=true
        end
        serverInfo(json)                               
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=AppServerInfo.new("itunes-remote-server-info.rb")
    app.exec(args)
end

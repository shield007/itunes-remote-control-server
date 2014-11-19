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

class CheckCacheApp < ItunesController::RemoteApplication          
    
    # Display the command line usage of the application
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options] files...") 
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())            
        @stdout.puts("    -r, --regenerated-cache          If this option is given, then it will force the cache to be regenerated")
    end     

    def parseAppOptions(opts)
        opts.on('-r','--regenerated-cache','If this option is given, then it will force the cache to be regenerated') do
            @options[:regenerate_cache] = true;
        end        
    end       
    
    # Used to check the cache
    def checkCache(force)
        if (force)
            sendCommand(ItunesController::CommandName::CHECKCACHE+":true",ItunesController::Code::OK.to_i,@stdout)
        else
            sendCommand(ItunesController::CommandName::CHECKCACHE+":false",ItunesController::Code::OK.to_i,@stdout)
        end
                    
    end 
    
    # Call the server to list dead tracks
    # @param args The arguments passed to the application
    def execApp(args)
        force = false
        if @options[:regenerate_cache]==true
            force=true
        end        
        checkCache(force)
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=CheckCacheApp.new("itunes-remote-check-cache.rb")
    app.exec(args)    
end


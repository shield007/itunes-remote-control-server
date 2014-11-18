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
    
    def displayUsage()
        puts("Usage: "+@appName+" [options] files...") 
        puts("")
        puts(genericOptionDescription())            
        puts("    -r, --regenerated-cache          If this option is given, then it will force the cache to be regenerated")
    end     

    def parseAppOptions(opts)
        opts.on('-r','--regenerated-cache','If this option is given, then it will force the cache to be regenerated') do
            @options[:regenerate_cache] = true;
        end        
    end        
    
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


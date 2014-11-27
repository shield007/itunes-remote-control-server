#!/usr/bin/ruby -I../lib
#
# The MIT License (MIT)
# 
# Copyright (c) 2011-2014 John-Paul Stanford <dev@stanwood.org.uk>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011-2014  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: The MIT License (MIT) <http://opensource.org/licenses/MIT>
#

#
# A command line util used to add tracks to the iTunes library
#

this_dir = File.dirname(__FILE__)            
lib_dir  = File.join(this_dir,  '..', 'lib')
$: << lib_dir

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

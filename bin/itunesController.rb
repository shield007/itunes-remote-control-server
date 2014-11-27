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

this_dir = File.dirname(__FILE__)            
lib_dir  = File.join(this_dir,  '..', 'lib')
$: << lib_dir

require 'rubygems'
require 'pathname'
require 'itunesController/config'
require 'itunesController/server/server'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/cachedcontroller'
require 'itunesController/application'
require 'itunesController/sequel_creator'

class App < ItunesController::Application

    DEFAULT_PORT=7000

    # Used to display the command line useage
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options]")
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())
        @stdout.puts("    -p, --port PORT                  The port number to start the server on. Defaults to #{DEFAULT_PORT}")
        @stdout.puts("    -c, --config FILE                The configuration file")
    end

    def checkAppOptions()
        if (@options[:config]==nil)
            usageError("No config file specified. Use --config option.")
        end
    end

    def parseAppOptions(opts)
        opts.on('-p','--port PORT','The port number to start the server on. Defaults to 7000') do |port|
            @options[:port] = port;
        end
        opts.on('-c','--config FILE','The configuration file') do |value|
            @options[:config] = value
        end
    end
    
    def readConfig()
    end
    
    def createController()
        return ItunesController::SequelControllerCreator.new()
    end

    def execApp(controllerCreator)        
        port=DEFAULT_PORT        
        if (@config.port!=nil) 
            port = @config.port
        end
        if (@options[:port]!=nil)
            port = @options[:port]
        end
        server=ItunesController::ITunesControlServer::runServer(@config,port,controllerCreator)        
        server.join
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    app=App.new("itunesController.rb")
    app.exec()
end

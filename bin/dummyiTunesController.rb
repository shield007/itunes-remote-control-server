#!/usr/bin/ruby -I../lib
#
# Copyright (C) 2011-2012  John-Paul.Stanford <dev@stanwood.org.uk>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'tempfile'

require 'itunesController/controller_creator'
require 'itunesController/config'
require 'itunesController/controllserver'
require 'itunesController/itunes/dummy_itunescontroller'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/cachedcontroller'
require 'itunesController/application'
require 'itunesController/database/sequel_backend'

class DummyControllerCreator < ItunesController::ControllerCreator
    
    def initialize(controller)
        @controller = controller
    end
    
    def createController()
        return @controller
    end
end

class App < ItunesController::Application

    DEFAULT_PORT=7000

    def initialize(appName,dbPath)
        super(appName)
        @dbPath=dbPath
    end

    # Used to display the command line useage
    def displayUsage()
        $stdout.puts("Usage: "+@appName+" [options]")
        $stdout.puts("")
        $stdout.puts(genericOptionDescription())
        $stdout.puts("    -p, --port PORT                  The port number to start the server on. Defaults to #{DEFAULT_PORT}")
        $stdout.puts("    -c, --config FILE                The configuration file")
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

    def createController()
        ItunesController::DummyITunesController::resetCommandLog()
        ItunesController::DummyITunesController::resetTracks()
        itunes=ItunesController::DummyITunesController.new()
        dbBackend = ItunesController::SequelDatabaseBackend.new("sqlite://#{@dbPath}")      
        return DummyControllerCreator.new(ItunesController::CachedController.new(itunes,dbBackend))
    end

    def execApp(controllerCreator)
        port=DEFAULT_PORT
        config=ItunesController::ServerConfig.readConfig(@options[:config])
        if (config.port!=nil) 
            port = config.port
        end
        if (@options[:port]!=nil)
            port = @options[:port]
        end
        server=ItunesController::ITunesControlServer.new(config,port,controllerCreator)        
        server.join
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    dbFile = Tempfile.new('dummyDatabase.db')
    begin    
        ItunesController::ItunesControllerLogging::info("Started dummy iTunes controller with db path '#{dbFile.path}'")
        app=App.new("itunesController.rb",dbFile.path)
        app.exec()
    ensure
        dbFile.unlink
    end
end

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


require 'itunesController/config'
require 'itunesController/dummy_itunescontroller'
require 'itunesController/controllserver'

require 'rubygems'
require 'optparse'

def error(msg)
    $stderr.puts msg
    exit(1)
end

def displayUsage()
    puts("Usage: itunesController.rb [options]")
    puts("")
    puts("Specific options:")
    puts("    -p, --port PORT                  The port number to start the server on. Defaults to 7000")
    puts("    -c, --config FILE                The configuration file")
    puts("    -h, --help                       Display this screen")
end

def usageError(message)
    $stderr.puts "ERROR: "+message
    displayUsage()
    exit(1)
end

OPTIONS = {}
OPTIONS[:port] = nil
OPTIONS[:config] = nil

def checkOptions
    if (OPTIONS[:config]==nil)
        usageError("No config file specified. Use --config option.")
    end
end

optparse = OptionParser.new do|opts|
    opts.banner = "Usage: itunesController.rb [options]"
    opts.separator ""
    opts.separator "Specific options:"

    opts.on('-p','--port PORT','The port number to start the server on. Defaults to 7000') do |port|
        OPTIONS[:port] = port;
    end
    opts.on('-c','--config FILE','The configuration file') do |value|
        OPTIONS[:config] = value
    end

    opts.on_tail( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
    end
end

optparse.parse!
checkOptions()

controller = DummyITunesController.new
port = 7000
config=ServerConfig.readConfig(OPTIONS[:config])
if (config.port!=nil) 
    port = config.port
end
if (OPTIONS[:port]!=nil)
    port = OPTIONS[:port]
end
interfaceAddress = nil
server=ITunesControlServer.new(config,port,controller)
server.start
server.join

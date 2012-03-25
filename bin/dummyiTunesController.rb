#!/usr/bin/ruby -I../lib
#
# This is a ruby executable that is used to create a dummy itunes server. It's mostly intended for use 
# with tests.
# @example {
#   Usage: dummyItunesController.rb [options]
#
#   Specific options:
#    -p, --port PORT                  The port number to start the server on. Defaults to 7000
#    -c, --config FILE                The configuration file
#    -h, --help                       Display this screen
# }
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/config'
require 'itunesController/dummy_itunescontroller'
require 'itunesController/controllserver'
require 'itunesController/version'
require 'itunesController/debug'
require 'itunesController/logging'

require 'rubygems'
require 'optparse'

# Used to cause the application to exit with a error message
# @param [String] msg The error message
def error(msg)
    $stderr.puts msg
    exit(1)
end
    
# Used to display the command line useage
def displayUsage()
    puts("Usage: dummyItunesController.rb [options]")
    puts("")
    puts("Specific options:")
    puts("    -l, --log FILE                   Optional paramter used to log messages to")
    puts("    -p, --port PORT                  The port number to start the server on. Defaults to 7000")
    puts("    -c, --config FILE                The configuration file")
    puts("    -h, --help                       Display this screen")
end

# Used to display a error message and the command line usesage
# @param [String] message The error message
def usageError(message)
    $stderr.puts "ERROR: "+message
    displayUsage()
    exit(1)
end

OPTIONS = {}
OPTIONS[:port] = nil
OPTIONS[:config] = nil
OPTIONS[:logFile] = nil

# Used to check the command line options are valid
def checkOptions
    if (OPTIONS[:config]==nil)
        usageError("No config file specified. Use --config option.")
    end
end

optparse = OptionParser.new do|opts|
    opts.banner = "Usage: itunesController.rb [options]"
    opts.separator ""
    opts.separator "Specific options:"

    opts.on('-l','--log FILE','Optional paramter used to log messages to') do |value|
        OPTIONS[:logFile] = value
    end
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

ItunesController::ItunesControllerLogging::setLogFile(OPTIONS[:logFile])
controller = ItunesController::DummyITunesController.new
port = 7000
config=ItunesController::ServerConfig.readConfig(OPTIONS[:config])
if (config.port!=nil) 
    port = config.port
end
if (OPTIONS[:port]!=nil)
    port = OPTIONS[:port]
end
interfaceAddress = nil
server=ItunesController::ITunesControlServer.new(config,port,controller)
server.start
server.join

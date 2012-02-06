#!/usr/bin/ruby -I../lib/ruby

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

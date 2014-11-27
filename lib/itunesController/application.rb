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

require 'itunesController/cachedcontroller'
require 'itunesController/logging'
require 'itunesController/version'

require 'rubygems'
require 'optparse'

module ItunesController

    class Application               

        def initialize(appName)
            @appName = appName
            @options = {}
            @options[:logFile] = nil
            @config = nil
        end

        def genericOptionDescription()
            result=[]
            result.push("Specific options:")
            result.push("    -f, --log_file FILE              Optional paramter used to log messages to")
            result.push("    -l, --log_config LEVEL           Optional paramter used to log level [DEBUG|INFO|WARN|ERROR]")               
            result.push("    -v, --version                    Display version of the application")
            result.push("    -h, --help                       Display this screen")
            return result.join("\n")
        end

        # Used to display the command line useage
        def displayUsage()
            puts("Usage: "+@appName+" [options]")
            puts("")
            puts(genericOptionDescription())
        end

        # Used to display a error message and the command line usesage
        # @param [String] message The error message
        def usageError(message)
            $stderr.puts "ERROR: "+message
            displayUsage()
            exit(1)
        end

        # Used to check the command line options are valid
        def checkOptions
            checkAppOptions
        end

        def parseOptions
            optparse = OptionParser.new do|opts|
                opts.banner = "Usage: "+@appName+" [options]"
                opts.separator ""
                opts.separator "Specific options:"

                opts.on('-f','--log_file FILE','Optional paramter used to log messages to') do |value|
                    @options[:logFile] = value
                    ItunesController::ItunesControllerLogging::setLogFile(@options[:logFile])
                end
                opts.on('-l','--log_config LEVEL','Optional paramter used to log level [DEBUG|INFO|WARN|ERROR]') do |value|
                    @options[:logConfig] = value
                    ItunesController::ItunesControllerLogging::setLogLevelFromString(@options[:logConfig])
                end
                parseAppOptions(opts)

                opts.on_tail( '-v', '--version', 'Display version of the application' ) do
                    puts "itunes-remote-control-server "+ItunesController::VERSION
                    puts "Copyright (c) 2011-2014 John-Paul Stanford <dev@stanwood.org.uk>"
                    puts "The MIT License (MIT) <http://opensource.org/licenses/MIT>."
                    puts ""
                    puts "Authors: John-Paul Stanford <dev@stanwood.org.uk>"
                    puts "Website: http://code.google.com/p/itunes-remote-control-server/"
                end
                opts.on_tail( '-h', '--help', 'Display this screen' ) do
                    puts opts
                    exit
                end
                end
            optparse.parse!
            checkOptions()
        end        
    
        def exec()
            ItunesController::ItunesControllerLogging::debug("Start application")
            parseOptions()
            readServerConfig()
            controllerCreator = createController()
            ItunesController::ItunesControllerLogging::debug("Controller Created")
            execApp(controllerCreator)
            #controller.close()
        end

        def getOptions()
            return @options
        end

        def parseAppOptions(opts)
        end

        def checkAppOptions()
        end
        
        def readServerConfig()            
            @config=ItunesController::ServerConfig.readConfig(@options[:config])
        end

        def execApp(controllerCreator)
            raise "ERROR: Your trying to instantiate an abstract class"
        end

    end
end

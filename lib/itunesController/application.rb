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


require 'itunesController/cachedcontroller'
require 'itunesController/logging'
require 'itunesController/version'
require 'itunesController/database/sqlite3_backend'

require 'rubygems'
require 'optparse'

module ItunesController

    class Application

        def initialize(appName)
            @appName = appName
            @options = {}
            @options[:logFile] = nil
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
                    puts "Copyright (C) 2012 John-Paul Stanford"
                    puts "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
                    puts "This is free software: you are free to change and redistribute it."
                    puts "There is NO WARRANTY, to the extent permitted by law."
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

        def createController()
            dbBackend = ItunesController::SQLite3DatabaseBackend.new(nil)
            return ItunesController::CachedController.new(ItunesController::ITunesControllerFactory::createController(),dbBackend)
        end
    
        def exec()
            parseOptions
            controller = createController()
            execApp(controller)
            #controller.close()
        end

        def getOptions()
            return @options
        end

        def parseAppOptions(opts)
        end

        def checkAppOptions()
        end

        def execApp(controller)
            raise "ERROR: Your trying to instantiate an abstract class"
        end

    end
end

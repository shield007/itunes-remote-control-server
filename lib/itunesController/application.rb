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
            result.push("    -l, --log FILE                   Optional paramter used to log messages to")
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
                opts.on('-l','--log_config FILE','Optional paramter used to log level [DEBUG|INFO|WARN|ERROR]') do |value|
                    @options[:logConfig] = value
                    ItunesController::ItunesControllerLogging::setLogLevelFromString(@options[:logConfig])
                end
                parseAppOptions(opts)

                opts.on_tail( '-h', '--help', 'Display this screen' ) do
                    puts opts
                    exit
                end
            end
            optparse.parse!
            checkOptions()
        end
    
        def exec()
            parseOptions
            controller = ItunesController::CachedController.new
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

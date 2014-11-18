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

require 'log4r'
include Log4r

module ItunesController    
    
    class ItunesControllerLogging                      
        @@log = Logger.new("log")
        
        @@log.outputters = Outputter.stdout
        @@log.level = Log4r::INFO
              
        # Used to set the location of the log file
        # @param [String] file The log file location
        def self.setLogFile(file)
            format = PatternFormatter.new(:pattern => "[%l] %d :: %m")
            file = FileOutputter.new('fileOutputter', :filename => file,:trunc => false, :formatter => format)
            @@log.add(file)
        end               
        
        def self.setLogLevelFromString(level)
            if (level=="DEBUG")
              @@log.level = Log4r::DEBUG
            elsif (level=="INFO")
              @@log.level = Log4r::INFO
            elsif (level=="WARN")
              @@log.level = Log4r::WARN
            elsif (level=="ERROR")
              @@log.level = Log4r::ERROR
            else
                error("Unknown log configuration '#{level}'")
                exit(1)
            end
        end
        
        # Used to print logging information at info level
        # @param [String] msg The message to print
        def self.info(msg)
            @@log.info(msg)
        end        

        # Used to print logging information at warn level
        # @param [String] msg The message to print
        def self.warn(msg)
            @@log.warn(msg)
        end        
        
        # Used to print logging information at debug level
        # @param [String] msg The message to print
        def self.debug(msg)
            @@log.debug(msg)
        end       
        
        # Used to print logging information at debug level
        # @param [String] msg The message to print
        # @param exception If not nil then this exception detials will be printed
        def self.error(msg,exception=nil)
            @@log.error(msg)                        
            if (exception!=nil)
                @@log.error("#{exception.class.name}: "+exception.message)
                exception.backtrace.each do | trace | 
                    @@log.error("  * " + trace)
                end
            end            
        end                           
    end
end

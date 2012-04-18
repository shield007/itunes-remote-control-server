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

module ItunesController    
    
    class ItunesControllerLogging     
        DEBUG=1   
        INFO=2
        WARN=3
        ERROR=4          
        
        # The log file, if defined then logging opertions will be sent to this file
        @@logFile = nil       
        @@logLevel = INFO
        
        # Used to set the location of the log file
        # @param [String] file The log file location
        def self.setLogFile(file)
            @@logFile = file 
        end
        
        # Use to set the loggin level
        # @param [Number] level The logging level
        def self.setLogLevel(level)
            @@logLevel = level
        end
        
        def self.setLogLevelFromString(level)
            if (level=="DEBUG")
                @@logLevel = DEBUG
            elsif (level=="INFO")
                @@logLevel = INFO
            elsif (level=="WARN")
                @@logLevel = WARN
            elsif (level=="ERROR")
                @@logLevel = ERROR
            else
                error("Unkown log configuration '#{level}'")
                exit(1)
            end
        end
        
        # Used to print logging information at info level
        # @param [String] msg The message to print
        def self.info(msg)
            if @@logLevel <= INFO            
                printMsg(msg)
            end
        end        

        # Used to print logging information at warn level
        # @param [String] msg The message to print
        def self.warn(msg)
            if @@logLevel <= WARN            
                printMsg(msg)
            end
        end        
        
        # Used to print logging information at debug level
        # @param [String] msg The message to print
        def self.debug(msg)
            if @@logLevel <= DEBUG
                msg="DEBUG:"+msg
                printMsg(msg)
            end
        end       
        
        # Used to print logging information at debug level
        # @param [String] msg The message to print
        # @param exception If not nil then this exception detials will be printed
        def self.error(msg,exception=nil)
            if @@logLevel <= ERROR
                msg="ERROR:"+msg
                printMsg(msg,true)        
                if (exception!=nil)                
                    printMsg("     - #{exception.message}",true)
                    exception.backtrace.each do | line |
                        printMsg("     * #{line}",true)
                    end
                end
            end       
        end                  
    
    private
    
        def self.printMsg(msg,error=false)
            if (@@logFile!=nil) 
                out_file = File.open(@@logFile,"a") do | f |
                    f.puts(msg) 
                end
            else                
                if (error)
                    $stderr.puts(msg)
                else
                    $stdout.puts(msg)                                   
                end
                
            end        
        end
    end
end

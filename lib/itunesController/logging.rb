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
        @@logLevel = DEBUG
        
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
        
        
        # Used to print logging information at info level
        # @param [Stirng] msg The message to print
        def self.info(msg)
            if @@logLevel <= INFO            
                printMsg(msg)
            end
        end        
        
        # Used to print logging information at debug level
        # @param [Stirng] msg The message to print
        def self.debug(msg)
            if @@logLevel <= DEBUG
                msg="DEBUG:"+msg
                printMsg(msg)
            end
        end       
        
        # Used to print logging information at debug level
        # @param [Stirng] msg The message to print
        def self.error(msg)
            if @@logLevel <= ERROR
                msg="ERROR:"+msg
                printMsg(msg)        
            end       
        end   
    
    private
    
    def self.printMsg(msg)
        if (@@logFile!=nil) 
            out_file = File.new(@@logFile,"w") do | f |
                f.puts(msg) 
            end
        else                
            puts(msg)
        end        
    end
    end
end

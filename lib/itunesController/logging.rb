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

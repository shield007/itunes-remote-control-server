#!/usr/bin/ruby -I../lib
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

#
# A command line util used to add tracks to the iTunes library
#

this_dir = File.dirname(__FILE__)            
lib_dir  = File.join(this_dir,  '..', 'lib')
$: << lib_dir

require 'rubygems'
require 'pathname'
require 'itunesController/remote_application'

class AppAddFiles < ItunesController::RemoteApplication   
    
    # Display the command line usage of the application
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options] files...") 
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())
    end     
       
    # Send the add files command to the server
    def addFiles()
        sendCommand(ItunesController::CommandName::ADDFILES,ItunesController::Code::OK.to_i)        
    end
    
    # Register all the files to be added with the server, then send the command to add them
    # @param args The arguments passed to the application
    def execApp(args)
        if (args.length()==0)
            ItunesController::ItunesControllerLogging::error("No files given on the command line to add to iTunes")
        else
            count = 0
            args.each do | path |
                begin
                    file(path)
                    count=count +1
                rescue ItunesController::RemoteApplication::ErrorResponseException => e
                    if e.code = ItunesController::Code::NotFound
                        ItunesController::ItunesControllerLogging::error("Unable to add file #{path} to iTunes as it can't be found")                        
                    else
                        raise
                    end                          
                end                         
            end
            if count>0
                addFiles()
            end                        
            ItunesController::ItunesControllerLogging::info("#{count} files add to iTunes")            
        end                               
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)       
    args = ARGV
    app=AppAddFiles.new("itunes-remote-add-files.rb")
    app.exec(args)
end

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
# A command line utility to display track information
#

this_dir = File.dirname(__FILE__)            
lib_dir  = File.join(this_dir,  '..', 'lib')
$: << lib_dir

require 'rubygems'
require 'pathname'
require 'itunesController/remote_application'
require 'json'

class TrackInfoListTracks < ItunesController::RemoteApplication   
    
    # Display the command line usage of the application
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options] files...") 
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())
        @stdout.puts("    -j, --json                       If this option is given, output will be in JSON format")
    end
    
    # Parse the options for this application
    # @param opts The OptionParser
    def parseAppOptions(opts)
        opts.on('-j','--json','If this option is given, output will be in JSON format') do
            @options[:json] = true;
        end        
    end    

    # Print track information to stdout
    # @param path The location of the track to print information for        
    def infoTrackByPathText(path)
        result = getTrackInfo(path)        
        result.each do | k,v |
            @stdout.puts("#{k}: #{v}")
        end        
        @stdout.puts("\n")
    end
    
    # Get the information about a track
    # @param path The location of the track to print information for
    # @return Hash with the track info
    def getTrackInfo(path)
        result=sendCommand(ItunesController::CommandName::TRACKINFO+':path:'+path,ItunesController::Code::OK.to_i,nil,[ItunesController::Code::NotFound])                    
        result = JSON.parse(result)
        return result
    end
    
    # Called when the application is executed to display track information
    # @param args The arguments passed to the application
    def execApp(args)        
        if (args.length()==0)
            ItunesController::ItunesControllerLogging::error("No files given on the command line")
        else
            json = false
            if @options[:json]==true
                json=true
            end
            if json
                result = []
                errors = []
                args.each do | path |                    
                    begin
                        result << getTrackInfo(path)
                    rescue ItunesController::RemoteApplication::ErrorResponseException => e
                        if e.code = ItunesController::Code::NotFound
                            errors << "Unable to find track in iTunes #{path}"
                        else
                            raise
                        end                          
                    end                            
                end
                if errors.count > 0
                    @stdout.puts(JSON.pretty_generate({ :errors => errors}))
                else
                    @stdout.puts(JSON.pretty_generate(result))
                end
            else
                args.each do | path |
                    begin                
                        infoTrackByPathText(path)
                    rescue ItunesController::RemoteApplication::ErrorResponseException => e
                        if e.code = ItunesController::Code::NotFound
                            @stderr.puts("Unable to find track in iTunes #{path}")
                        else
                            raise
                        end
                    end                       
                end    
            end        
        end                                          
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=TrackInfoListTracks.new("itunes-remote-track-info.rb")
    app.exec(args)
end

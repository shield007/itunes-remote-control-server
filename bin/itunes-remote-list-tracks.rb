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
# A command line util used to list tracks found by the server
#

this_dir = File.dirname(__FILE__)            
lib_dir  = File.join(this_dir,  '..', 'lib')
$: << lib_dir

require 'rubygems'
require 'pathname'
require 'itunesController/remote_application'

class AppListTracks < ItunesController::RemoteApplication   
    
    # Display the command line usage of the application
    def displayUsage()
        @stdout.puts("Usage: "+@appName+" [options]") 
        @stdout.puts("")
        @stdout.puts(genericOptionDescription())
    end
    
    # Called to send the commands to the server that will list tracks found by the server.
    # The tracks are printed to stdout
    def listTracks()
        result=sendCommand(ItunesController::CommandName::LISTTRACKS,ItunesController::Code::OK.to_i)
        result = JSON.parse(result)
        tracks = result['tracks']
        if (tracks==nil or tracks.length()==0)
            @stdout.puts("No tracks found")
        else
            tracks.each do | track |
                @stdout.puts("Location: #{track['location']} - Title: #{track['title']} - DatabaseId: #{track['databaseId']}")
            end            
        end            
    end
    
    # Call the server to list tracks
    # @param args The arguments passed to the application
    def execApp(args)
        listTracks()                               
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    args = ARGV
    app=AppListTracks.new("itunes-remote-list-tracks.rb")
    app.exec(args)
end

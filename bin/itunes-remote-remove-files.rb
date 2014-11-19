#!/usr/bin/ruby -I../lib
#
# A command line util used to add tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'itunesController/remote_application'

class AppRemoveFiles < ItunesController::RemoteApplication   
    
    # Display the command line usage of the application
    def displayUsage()
        puts("Usage: "+@appName+" [options] files...") 
        puts("")
        puts(genericOptionDescription())
    end
    
    # Send the remove files command to the server
    def removeFiles()
        sendCommand(ItunesController::CommandName::REMOVEFILES,ItunesController::Code::OK.to_i)
    end
    
    # Register all the files to be removed with the server, then send the command to remove them
    # @param args The arguments passed to the application
    def execApp(args)
        if (args.length()==0)
            ItunesController::ItunesControllerLogging::error("No files given on the command line to remove from iTunes")
        else
            args.each do | path |
                file(path)                       
            end
            removeFiles()
        end                               
    end
end

if __FILE__.end_with?(Pathname.new($0).basename.to_s)
    app=AppRemoveFiles.new("itunes-remote-remove-files.rb")
    app.exec(args)
end

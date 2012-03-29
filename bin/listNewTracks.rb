#!/usr/bin/ruby -I../lib
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

require 'itunesController/application'
require 'itunesController/logging'

require 'rubygems'
require 'fileutils'

class App < ItunesController::Application

    MEDIA_TYPES = [".m4v","mp3",".mp4"]

    # Used to display the command line useage
    def displayUsage()
        puts("Usage: "+@appName+" [options] directories...")
        puts("")
        puts("Specific options:")
        puts("    -l, --log FILE                   Optional paramter used to log messages to")
        puts("    -h, --help                       Display this screen")
    end

    def checkAppOptions()
        if ARGV.length == 0
            usageError("No directories given.")
        end
        ARGV.each do | path |
            errors = false
            if (!File.exists?(path) || !File.directory?(path))
               ItunesController::ItunesControllerLogging::error("#{path} is not a directory or cannot be found") 
               errors = true
            end 
            if (errors)
                exit(1)
            end
        end
    end

    def processMediaFiles ( controller,dir )
        (Dir.entries(dir)- %w[ . .. ]).each { |name|
            file=dir+"/"+name
            if (!File.directory?(file))
                ext=File.extname(file)
                name=File.basename(file)
                if (MEDIA_TYPES.index(ext)!=nil)
                    if (!controller.trackInLibrary?(file))
                        ItunesController::ItunesControllerLogging::info("#{file}") 
                    end
                end
            else
                processMediaFiles(controller,file)
            end
        }
    end

    def execApp(controller)
        ARGV.each do | path |
            ItunesController::ItunesControllerLogging::info("Checking for new files in '#{path}'") 
            processMediaFiles(controller,path)
        end
    end
end

app=App.new("listNewTracks.rb")
app.exec()

#!/usr/bin/env ruby -I ../lib/ruby
#
# This is a problem to scan a list of media directiores for files that are not
# in a itunes library.
#
# This application has been written for macosx's version of ruby, so it must
# be run using the mac ruby interpter.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'itunesController/macosx_itunescontroller'

require 'rubygems'
require 'fileutils'

# The media directiores to search
DIRS=["/mounts/incomming","/mounts/TVShows","/mounts/Films"]
    
# The file extensions to be considered as media files
MEDIA_TYPES = [".m4v","mp3",".mp4"]
    
# Updates a list of files with with the media files found with a directory.
# This will recursivly search for meadia files
# ::files
#   This is a list that all the found media files are added to
# ::dir
#   The media directory to look for files in
def listMediaFiles ( files,dir )
    (Dir.entries(dir)- %w[ . .. ]).each { |name|
        file=dir+"/"+name
        if (!File.directory?(file))
            ext=File.extname(file)
            name=File.basename(file)
            if (MEDIA_TYPES.index(ext)!=nil)
            files.push(file)
            end
        else
            listMediaFiles(files,file)
        end
    }
end

# Returns a list of media files that are have not been added to the
# itunes library
# ::libraryTracks 
#   The tracks within the library
def findNewMediaFiles(libraryTracks)
    libraryFiles=[]
    libraryTracks.each do | track |
        if (track.location.isFileURL)
            libraryFiles.push(track.location.path)
        end
    end
    files=[]
    DIRS.each do | dir | 
        listMediaFiles(files,dir)
    end    
    
    files.delete_if{|file| libraryFiles.index(file)!=nil}

    return files
end

controller = MacOSXITunesController.new
newFiles=findNewMediaFiles(controller.listFilesInLibrary())
newFiles.each do | file |
    puts(file)
end
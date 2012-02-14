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

# References:
#  - http://code.google.com/p/itunes-rem-dupes/source/browse/trunk/itunes_update_library.rb?r=22
#  - http://guides.macrumors.com/Deleting_Songs_From_iTunes
#  - http://macscripter.net/viewtopic.php?id=22726

require 'itunesController/itunescontroller'
require 'escape'
require 'itunesController/kinds'
require 'osx/cocoa'

include OSX
OSX.require_framework 'ScriptingBridge'
module ItunesController
    
    # This is a iTunes controller class used to talk to itunes. This runs on macosx and makes
    # use of the OSC ruby bindings. It also uses application "osascript" to execute apple scripts. 
    class MacOSXITunesController < ITunesController
        
        # The constructor
        def initialize
            @iTunes = SBApplication.applicationWithBundleIdentifier:'com.apple.iTunes'
            library=getSourceLibrary()
            @libraryPlaylists=library.libraryPlaylists
        end
    
        # Used to get the libaray play lists
        # @return The iTunes playlist
        def getLibraryPlaylists
            return @libraryPlaylists
        end
    
        # Used to get the iTunes version
        # @return [String] The itunes version
        def version
            return @iTunes.version
        end
    
        # Used to remove tracks from the libaray        
        # @param [Array] tracks A list of tracks to remove from the itunes libaray
        def removeTracksFromLibrary(tracks)            
            tracks.reverse.each do | track |
                track.delete
            end
        end

        # Used to add a list of files to the itunes library        
        # @param [Array[String]] A list of files to add to the itunes library    
        def addFilesToLibrary(files)
            script="tell application \"iTunes\"\n"
            files.each do | file |
                script=script+"    add POSIX file \"#{file}\"\n"
            end
            script=script+"end tell\n"
            executeScript(script)
        end
    
        # Used to get the libaray iTunes source        
        # @return The iTunes source for the library
        def getSourceLibrary()
            @iTunes.sources.each do |source|
                if (source.kind == SourceKind::Library.kind)
                return source
                end
            end
            return nil
        end
    
        # Used to get a list of tracks that have the given locations
        # @param [Array[String]] locations a list of track locations to find
        # @return [Array] A list of tracks that were found 
        def findTracksWithLocations(locations)
            tracks=[]
            @libraryPlaylists.each do | playlist |
                playlist.fileTracks.each do |track|
                    if (track.location.isFileURL)
                        if (locations.index(track.location.path))
                        return tracks.push(track)
                        end
                    end
                end
            end
            return tracks
        end
    
        # Used to get a track with the given location
        # @param [String] location The location of the track to find
        # @return The track that was found, or nil if it could not be found
        def findTrackWithLocation(location)
            @libraryPlaylists.each do | playlist |
                playlist.fileTracks.each do |track|
                    if (track.location.isFileURL)
                        if (track.location.path==location)
                        return track
                        end
                    end
                end
            end
            return nil
        end
    
        # Used to find the dead tracks (tracks whoes file references don't exist) within the
        # iTunes libaray
        # @return [Array] A list of dead tracks
        def findDeadTracks()
            deadTracks=[]
            @libraryPlaylists.each do | playlist |
                playlist.fileTracks.each do | track |
                    if (track.location==nil)
                        deadTracks.push(track)
                    elsif (track.location!=nil && track.location.isFileURL)
                        if (!File.exist?(track.location.path))
                            deadTracks.push(track)
                        end
                    end
                end
            end
            return deadTracks
        end
    
        # Used to list all the files in the library
        # @abstract Must be overridden
        # @return [Array] A list of files in the iTunes library
        def listFilesInLibrary()
            files=[]
            @libraryPlaylists.each do | playlist |
                playlist.fileTracks.each do |track|                                       
                    if (track.location !=nil && track.location.isFileURL)
                        files.push(track)
                    end
                end
            end
            return files
        end
    
        # Used to find playlists of a given media kind
        # @param types The types 
        # @return [Array] A list of playlists
        def findPlaylists(types)
            playlists=[]
            library=getSourceLibrary()
            if (library==nil)
                error("Unable to find iTunes library")
            end
    
            library.userPlaylists.each do |pl|
                kind=SpecialKind::fromKind(pl.specialKind)
                types.each do |type|
                    if (kind.kind == type.kind)
                    playlists.push(pl)
                    end
                end
            end
    
            return playlists
        end
    
    private
    
        # Used to execute a apple script using the system "osascript" command.
        # @private
        # @param script the Script contents        
        def executeScript(script)
            system(Escape.shell_command("osascript","-e",script))
        end
    end
end
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

require 'osx/cocoa'
require 'itunesController/itunescontroller'
require 'itunesController/kinds'

include OSX
OSX.require_framework 'ScriptingBridge'
module ItunesController
    class MacOSXITunesController < ITunesController
        
        def initialize
            @iTunes = SBApplication.applicationWithBundleIdentifier:'com.apple.iTunes'
            library=getSourceLibrary()
            @libraryPlaylists=library.libraryPlaylists
        end
    
        def getLibraryPlaylists
            return @libraryPlaylists
        end
    
        def version
            return @iTunes.version
        end
    
        def removeTracksFromLibrary(tracks)
            pl = getLibraryPlaylists()[0]
            tracks.reverse.each do | track |
                track.delete
            end
        end
    
        def addFilesToLibrary(files)
            script="tell application \"iTunes\"\n"
            files.each do | file |
                script=script+"    add POSIX file \"#{file}\"\n"
            end
            script=script+"end tell\n"
            executeScript(script)
        end
    
        def getSourceLibrary()
            @iTunes.sources.each do |source|
                if (source.kind == SourceKind::Library.kind)
                return source
                end
            end
            return nil
        end
    
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
    
        def executeScript(script)
            system("osascript -e '"+script+"'")
        end
    end
end
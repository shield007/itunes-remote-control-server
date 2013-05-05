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
require 'itunesController/kinds'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/track'
require 'rubygems'
require 'escape'
require 'open3'
require 'osx/cocoa'

include OSX
OSX.require_framework 'ScriptingBridge'

module ItunesController

    # This is a iTunes controller class used to talk to itunes. This runs on macosx and makes
    # use of the OSC ruby bindings. It also uses application "osascript" to execute apple scripts.
    class MacOSXITunesController < ItunesController::BaseITunesController

        # The constructor
        def initialize()
            @iTunes = SBApplication.applicationWithBundleIdentifier:'com.apple.iTunes'
            library=getSourceLibrary()
            @libraryPlaylists=library.libraryPlaylists
        end

        # Used to get the iTunes version
        # @return [String] The itunes version
        def version
            return @iTunes.version.to_s+" (Mac OSX)"
        end

        # Used to tell iTunes to refresh a list of tracks data from the info stored in the files
        # @param [Array] tracks A list of tracks to fresh
        def refreshTracks(tracks)
            ItunesController::ItunesControllerLogging::info("refreshing tracks...")
            tracks.reverse.each do | track |
                ItunesController::ItunesControllerLogging::debug("Refershing track #{track.location.pathh}")
                track.refresh
            end
        end

        # Used to remove tracks from the libaray
        # @param [Array] tracks A list of tracks to remove from the itunes libaray
        def removeTracksFromLibrary(tracks)
            ItunesController::ItunesControllerLogging::info("removing tracks...")
            tracks.reverse.each do | track |
                ItunesController::ItunesControllerLogging::debug("Removing track #{track.location.pathh}")
                track.delete
            end
        end

        # Used to add a list of files to the itunes library
        # @param [Array[String]] files A list of files to add to the itunes library
        # @return [Array[ItunesController::Track]] List of ids of the new tracks once they are in the database
        def addFilesToLibrary(files)
            tracks=[]
            files.each do | file |
                url=NSURL.fileURLWithPath(file)
                added=@iTunes.add_to_([url],@libraryPlaylists[0])
                ItunesController::ItunesControllerLogging::debug("Added track #{added}")
                if added
                    track=ItunesController::Track.new(file,added.databaseID.to_i,added.name)
                    tracks.push(track)
                else
                    ItunesController::ItunesControllerLogging::error("Unable to add file '#{file}'")
                end
            end

            return tracks;
        end

        # Used to get the database of a itunes track
        # @param track the track
        # @return The database id
        def getTrackDatabaseId(track)
            return track.databaseID
        end
        
        def getTracks(&b)
            ItunesController::ItunesControllerLogging::debug("Retrieving track information...")
            playlist=@libraryPlaylists[0]
            fileTracks = playlist.fileTracks
            size = fileTracks.length()
            count = 1
            fileTracks.each do | track |
                location=track.location
                path=nil
                dead=false
                if (location!=nil && location.isFileURL)
                    path=location.path
                    if (!File.exist?(location.path))
                        dead = true
                    end
                else
                    dead = true
                end

                if (count % 1000 == 0)
                    ItunesController::ItunesControllerLogging::debug("Found tracks #{count} of #{size}")
                end
                if (track.name!=nil)
                    controllerTrack = ItunesController::Track.new(path,track.databaseID,track.name) 
                    controllerTrack.watchCount=track.playedCount
                    controllerTrack.kind=VideoKind::fromKind(track.videoKind.to_i)
                    controllerTrack.seasonNumber=track.seasonNumber.to_i
                    controllerTrack.episodeNumber=track.episodeNumber.to_i
                    controllerTrack.showName=track.show.to_s
                    controllerTrack.title=track.name.to_s
                    
                    b.call(controllerTrack,count,size,dead)
                end
                count=count+1
            end
            ItunesController::ItunesControllerLogging::debug("Found tracks #{count-1} of #{size}")
            return size
        end

        # Used to find the number of tracks in the library
        # @return [Number] The number of tracks
        def getTrackCount()
            playlist=@libraryPlaylists[0]
            return playlist.fileTracks.length()
        end

        # Used to search the itunes library
        # @param term The search term
        # @return [Array] a list of iTunes track that match the search term
        def searchLibrary(term)
            tracks=[]
            @libraryPlaylists.each do | playlist |           
                #foundTracks = playlist.searchFor(term,'kSrS')
                foundTracks = playlist.searchFor_only_(term,1799449708)
                if (foundTracks!=nil)
                    foundTracks.each do | t |
                        tracks.push(t)
                    end
                end
            end
            return tracks
        end

    private

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

        # Used to find playlists of a given media kind
        # @param types The types
        # @return [Array] A list of playlists
        def findPlaylists(types)
            playlists=[]
            library=getSourceLibrary()
            if (library==nil)
                raise("Unable to find iTunes library")
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

        # Used to execute a apple script using the system "osascript" command.
        # @private
        # @param script the Script contents
        def executeScript(script)
            stdin, stdout, stderr = Open3.popen3(Escape.shell_command(["osascript","-e",script]))
            return stdout.readlines.join('\n').strip
        end
    end
end

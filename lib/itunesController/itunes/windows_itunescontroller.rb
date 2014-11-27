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

require 'itunesController/itunes/itunescontroller'
require 'itunesController/kinds'
require 'itunesController/debug'
require 'itunesController/logging'
require 'win32ole'

module ItunesController

    class WindowsITunesController < ItunesController::BaseITunesController

        # The constructor
        def initialize
            @iTunes = WIN32OLE.new('iTunes.Application')
            @libraryPlaylists=@iTunes.LibraryPlaylist
        end

        # Used to get the iTunes version
        # @return [String] The itunes version
        def version
            return @iTunes.version.to_s+" (Windows)"
        end

        # Used to tell iTunes to refresh a list of tracks data from the info stored in the files
        # @param [Array] tracks A list of tracks to fresh
        def refreshTracks(tracks)
            tracks.reverse.each do | track |                
                track.UpdateInfoFromFile
            end
        end

        # Used to remove tracks from the libaray
        # @param [Array] tracks A list of tracks to remove from the itunes libaray
        def removeTracksFromLibrary(tracks)
            tracks.reverse.each do | track |               
                track.Delete
            end
        end

        # Used to add a list of files to the itunes library
        # @param [Array[String]] files A list of files to add to the itunes library
        # @return [Array[ItunesController::Track]] List of ids of the new tracks once they are in the database
        def addFilesToLibrary(files)
            tracks=[]
            files.each do | file |
                if (!File.exist?(file))
                    ItunesController::ItunesControllerLogging::error("Unable to find file #{file}")
                else
                    itracks=@libraryPlaylists.AddFile(file)   
                    if (itracks!=nil)
                        itracks=itracks.Tracks                                                         
                        for i in (1..itracks.Count())                      
                            itrack=itracks.Item(i)
                            track=ItunesController::Track.new(file,itrack.TrackDatabaseID,itrack.Name)
                            tracks.push(track)
                        end                                                             
                    else
                        ItunesController::ItunesControllerLogging::error("Unable to add file '#{file}'")                         
                    end
                end
            end

            return tracks;
        end

        def getTracks(&b)
            ItunesController::ItunesControllerLogging::debug("Retriving track information...")
            playlist=@libraryPlaylists
            fileTracks = playlist.Tracks
            size = fileTracks.Count()
            count = 1
            for count in (1..size)
                track=fileTracks.Item(count)
                location=track.location            
                dead=false
                if (location!=nil)                   
                    if (!File.exist?(location))
                        dead = true
                    end
                else
                    dead = true
                end                
                if (count % 1000 == 0)
                    ItunesController::ItunesControllerLogging::debug("Found tracks #{count} of #{size}")
                end
                if (track.name!=nil)
                    controllerTrack = ItunesController::Track.new(location,track.TrackDatabaseID,track.name) 
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
            return @libraryPlaylists.Tracks.Count()
        end

        # Used to search the itunes library
        # @param term The search term
        # @return [Array] a list of iTunes track that match the search term
        def searchLibrary(term)
            tracks=[]
            playlist=@libraryPlaylists                             
            foundTracks = playlist.Search(term,1)            
            if (foundTracks!=nil)
                foundTracks.each do | t |
                    tracks.push(t)
                end
            end
           
            return tracks
        end              
        
        # Used to get the database of a itunes track
        # @abstract Must be overridden
        # @param track the track
        # @return The database id
        def getTrackDatabaseId(track)
            return track.TrackDatabaseID()
        end
    end
end

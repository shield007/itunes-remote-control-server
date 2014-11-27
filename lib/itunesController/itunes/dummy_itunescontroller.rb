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
require 'itunesController/track/dummy_itunes_track'

module ItunesController
    # This is a dummy implementation of the itunes controller which can be used
    # in tests to check that they talk to the server correctly. Any commands
    # that are recived are logged in the COMMNAD_LOG list. Tests can read
    # these to make sure they did the correct thing
    class DummyITunesController < ItunesController::BaseITunesController
                   
        # The constructor
        def initialize            
        end
        
        def self.getCommandLog()
            return @@commandLog
        end
        
        def self.resetCommandLog()
            @@commandLog=[]
        end
        
        def self.resetTracks()
            @@tracks=[]
        end
        
        def self.forceAddTrack(track)
            ItunesController::ItunesControllerLogging::debug("Force Adding track #{track}")
            dummyTrack=DummyItunesTrack.new(track.location,track.databaseId,track.title)
            @@tracks.push(dummyTrack)
        end

        def version
            return "Dummy"
        end

        # Used to tell iTunes to refresh a list of tracks data from the info stored in the files.
        # This is a dummy implementaion that is used with tests. It pushes messages into the
        # ItunesController::DummyITunesController::COMMAND_LOG so that tests can check the result.
        # @param tracks The tracks
        def refreshTracks(tracks)
            tracks.each do | track |
                ItunesController::ItunesControllerLogging::debug("Refresh track #{track}")
                @@commandLog.push("refreshTracks(#{track})")
            end
        end

        # Used to remove tracks from the libaray. This is a dummy implementaion that is used with tests.
        # It pushes messages into the ItunesController::DummyITunesController::COMMAND_LOG so that tests 
        # can check the result.
        # @param [Array] tracks A list of tracks to remove from the itunes libaray
        def removeTracksFromLibrary(tracks)
            tracks.each do | track |
                ItunesController::ItunesControllerLogging::debug("Remove track #{track}")
                @@commandLog.push("removeTracksFromLibrary(#{track})")
                @@tracks.delete(track)
            end
        end

        # Used to add a list of files to the itunes library. This is a dummy implementaion that is used 
        # with tests. It pushes messages into the ItunesController::DummyITunesController::COMMAND_LOG 
        # so that tests can check the result.
        # @param [Array[String]] files A list of files to add to the itunes library
        # @return [Array[ItunesController::Track]] List of ids of the new tracks once they are in the database
        def addFilesToLibrary(files)            
            tracks=[]          
            files.each do | file |                                                                             
                track=ItunesController::Track.new(file,@@tracks.length,"Test #{@@tracks.length}")                
                ItunesController::ItunesControllerLogging::debug("Adding track #{track}")              
                dummyTrack=DummyItunesTrack.new(track.location,track.databaseId,track.title)
                tracks.push(track)                
                @@tracks.push(dummyTrack)                           
                @@commandLog.push("addFilesToLibrary("+file+")")                
            end
            return tracks
        end               
        
        def findPlaylists(types)
            playlists=[]
            @@commandLog.push("findPlaylists(types)")
            return playlists
        end
        
        def getTrackCount()
            @@commandLog.push("getTrackCount() = #{@@tracks.length}")
            return @@tracks.length
        end
        
        def getTracks(&b)
            @@commandLog.push("getTracks()")
            for i in (0..@@tracks.length-1)
                track=@@tracks[i]                
                dead=!File.exist?(track.location)
                ItunesController::ItunesControllerLogging::debug("Getting track: #{track}, dead = #{dead}")
                b.call(ItunesController::Track.new(track.location,track.databaseID,track.name),i,@@tracks.length,dead)
            end
        end
             
        
        def searchLibrary(title)
            tracks=[]
            ItunesController::ItunesControllerLogging::debug("Searching for tracks with title '#{title}'")            
            @@tracks.each do | track |
                if (track.name == title)                    
                    tracks.push(track)                    
                    ItunesController::ItunesControllerLogging::debug("Found track '#{track}'")
                end
            end
            return tracks
        end
        
        # Used to get the database of a itunes track
        # @param track the track
        # @return The database id
        def getTrackDatabaseId(track)
            return track.databaseID
        end

    end
    
end


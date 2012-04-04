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
require 'itunesController/itunescontroller'
require 'itunesController/dummy_itunes_track'

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
        # @param track The track
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
        # @param [Array[String]] A list of files to add to the itunes library
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

    end
    
end


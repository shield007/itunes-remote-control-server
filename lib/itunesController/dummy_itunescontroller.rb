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

module ItunesController
    # This is a dummy implementation of the itunes controller which can be used
    # in tests to check that they talk to the server correctly. Any commands
    # that are recived are logged in the COMMNAD_LOG list. Tests can read
    # these to make sure they did the correct thing
    class DummyITunesController < ItunesController::BaseITunesController

        # The list of commands performed
        COMMAND_LOG = []
            
        # The constructor
        def initialize
            @@fileCount=0
        end
        
        def self.setFileCount(fileCount)
            @@fileCount = fileCount
        end

        def version
            return "Dummy"
        end

        # Used to tell iTunes to refresh a list of tracks data from the info stored in the files.
        # This is a dummy implementaion that is used with tests. It pushes messages into the
        # ItunesController::DummyITunesController::COMMAND_LOG so that tests can check the result.
        # @param track The track
        def refreshTracks(tracks)
            COMMAND_LOG.push("refreshTracks(tracks)")
            tracks.each do | track |
                COMMAND_LOG.push("refreshTracks("+track+")")
            end
        end

        # Used to remove tracks from the libaray. This is a dummy implementaion that is used with tests.
        # It pushes messages into the ItunesController::DummyITunesController::COMMAND_LOG so that tests 
        # can check the result.
        # @param [Array] tracks A list of tracks to remove from the itunes libaray
        def removeTracksFromLibrary(tracks)
            COMMAND_LOG.push("removeTracksFromLibrary(tracks)")
            tracks.each do | track |
                COMMAND_LOG.push("removeTracksFromLibrary("+track+")")
            end
        end

        # Used to add a list of files to the itunes library. This is a dummy implementaion that is used 
        # with tests. It pushes messages into the ItunesController::DummyITunesController::COMMAND_LOG 
        # so that tests can check the result.
        # @param [Array[String]] A list of files to add to the itunes library
        # @return [Array[ItunesController::Track]] List of ids of the new tracks once they are in the database
        def addFilesToLibrary(files)
            tracks=[]
            COMMAND_LOG.push("addFilesToLibrary(files)")            
            files.each do | file |                                                                             
                track=ItunesController::Track.new(file,@@fileCount,"Test #{@@fileCount}")                
                ItunesController::ItunesControllerLogging::debug("Adding track #{track}")              
                tracks.push(track)
                @@fileCount+=1                
                COMMAND_LOG.push("addFilesToLibrary("+file+")")                
            end
            return tracks
        end
        
        def findPlaylists(types)
            playlists=[]
            COMMAND_LOG.push("findPlaylists(types)")
            return playlists
        end
        
        def getTrackCount()
            COMMAND_LOG.push("getTrackCount()")
            return @@fileCount
        end
        
        def getTracks(&b)
            COMMAND_LOG.push("getTracks()")
            for i in (1..@@fileCount)
                b.call(ItunesController::Track.new("/blah/test#{i}.m4v",i,"Test #{i}"),i,@@fileCount,false)
            end
        end

    end
end

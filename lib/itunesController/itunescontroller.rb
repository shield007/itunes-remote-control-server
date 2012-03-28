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

module ItunesController  
    
    # This is the base class of all itunes controller.    
    # @abstract This class should be overridden to implement the class that talks to iTunes.
    class BaseITunesController

        # The constructor        
        def initialize()
        end
    
        # Used to get the libaray play lists
        # @abstract Must be overridden
        # @return The iTunes playlist
        def getLibraryPlaylists
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        # Used to get the iTunes version
        # @abstract Must be overridden
        # @return [String] The itunes version
        def version
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        # Used to remove tracks from the libaray
        # @abstract Must be overridden
        # @param [Array] tracks A list of tracks to remove from the itunes libaray
        def removeTracksFromLibrary(tracks)
            raise "ERROR: Your trying to instantiate an abstract class"
        end

        # Used to add a list of files to the itunes library
        # @abstract Must be overridden
        # @param [Array[String]] A list of files to add to the itunes library
        # @return [Array[ItunesController::Track]] List of ids of the new tracks once they are in the database
        def addFilesToLibrary(files)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
           
        # Used to get a list of tracks that have the given locations
        # @abstract Must be overridden
        # @param [Array[String]] locations a list of track locations to find
        # @return [Array] A list of tracks that were found 
        def findTracksWithLocations(locations)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        # Used to get a track with the given location
        # @abstract Must be overridden
        # @param [String] location The location of the track to find
        # @return The track that was found, or nil if it could not be found
        def findTrackWithLocation(location)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        # Used to find the dead tracks (tracks whoes file references don't exist) within the
        # iTunes libaray
        # @return [Array] A list of dead tracks
        def findDeadTracks()
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        # Used to list all the files in the library
        # @abstract Must be overridden
        # @return [Array] A list of files in the iTunes library
        def listFilesInLibrary()
            raise "ERROR: Your trying to instantiate an abstract class"
        end
           
        # Used to tell iTunes to refresh a list of tracks data from the info stored in the files
        # @abstract Must be overridden
        # @param [Array] tracks A list of tracks to fresh
        def refreshTracks(tracks)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
        
        # @abstract Must be overridden
        def getTracks(&b)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
        
        # Used to search the itunes library
        # @param term The search term
        # @return [Array] a list of iTunes track that match the search term
        # @abstract Must be overridden
        def searchLibrary(term)
            raise "ERROR: Your trying to instantiate an abstract class"
        end

        # Used to find the number of tracks in the library
        # @abstract Must be overridden
        # @return [Number] The number of tracks
        def getTrackCount()
            raise "ERROR: Your trying to instantiate an abstract class"
        end

    
    end
end

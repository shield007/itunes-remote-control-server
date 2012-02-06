#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#
require 'itunesController/itunescontroller'

# This is a dummy implementation of the itunes controller which can be used
# in tests to check that they talk to the server correctly. Any commands
# that are recived are logged in the COMMNAD_LOG list. Tests can read
# these to make sure they did the correct thing
class DummyITunesController < ITunesController 
    attr_reader :iTunes    

    # The list of commands performed 
    COMMAND_LOG = []
        
    # The constructor
    def initialize      
    end

    def getLibraryPlaylists
        return nil
    end
    
    def version
        return "Dummy"
    end

    def removeTracksFromLibrary(tracks)
        COMMAND_LOG.push("removeTracksFromLibrary(tracks)")
        tracks.each do | track |
            COMMAND_LOG.push("removeTracksFromLibrary("+track+")")
        end
    end

    def addFilesToLibrary(files)
        COMMAND_LOG.push("addFilesToLibrary(files)")
        files.each do | file |
            COMMAND_LOG.push("addFilesToLibrary("+file+")")
        end
        
    end

    def getSourceLibrary()        
        COMMAND_LOG.push("getSourceLibrary()")
        return nil
    end

    def findTracksWithLocations(locations)        
        COMMAND_LOG.push("findTracksWithLocations(locations)")
        return locations
    end

    def findTrackWithLocation(location)
        COMMAND_LOG.push("findTracksWithLocation(location)")        
        return nil
    end

    def findDeadTracks()
        deadTracks=[]        
        COMMAND_LOG.push("findDeadTracks()")
        return deadTracks
    end

    def listFilesInLibrary()
        files=[]        
        COMMAND_LOG.push("listFilesInLibrary()")
        return files
    end

    def findPlaylists(types) 
        playlists=[]
        COMMAND_LOG.push("findPlaylists(types)")
        return playlists
    end
end
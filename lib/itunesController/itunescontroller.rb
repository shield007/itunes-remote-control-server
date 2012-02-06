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
    
    class ITunesController
        
        def initialize
            
        end
    
        def getLibraryPlaylists
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def version
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def removeTracksFromLibrary(tracks)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def addFilesToLibrary(files)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def getSourceLibrary()
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def findTracksWithLocations(locations)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def findTrackWithLocation(location)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def findDeadTracks()
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def listFilesInLibrary()
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        def findPlaylists(types)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
    end
end
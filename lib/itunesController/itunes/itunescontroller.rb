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

module ItunesController  
    
    # This is the base class of all itunes controller.    
    # @abstract This class should be overridden to implement the class that talks to iTunes.
    class BaseITunesController

        # The constructor        
        def initialize()
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
        # @param [Array[String]] files A list of files to add to the itunes library
        # @return [Array[ItunesController::Track]] List of ids of the new tracks once they are in the database
        def addFilesToLibrary(files)
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

        # Used to get the database of a itunes track
        # @abstract Must be overridden
        # @param track the track
        # @return The database id
        def getTrackDatabaseId(track)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
    end
end

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

require 'itunesController/logging'
require 'itunesController/itunes/itunescontroller'
require 'itunesController/database/database'
require 'itunesController/track/track'

module ItunesController

    class CachedController

        def initialize(controller,databaseBackend)
            @controller = controller          
            @database = ItunesController::Database.new(@controller,databaseBackend)
            @cachedOnCreate=cacheTracks()
        end

        def getCachedTracksOnCreate()
            return @cachedOnCreate
        end

        def removeTrack(path)
            trackInfo=@database.getTrack(path)
            if (trackInfo==nil)
                ItunesController::ItunesControllerLogging::error("Unable to find track with path: "+path)
                return nil
            end
            removeTrackByInfo(trackInfo)
        end               

        def removeTrackByInfo(trackInfo)            
            ItunesController::ItunesControllerLogging::debug("Removing track: '#{trackInfo}'")
            foundTracks=@controller.searchLibrary(trackInfo.title)
            if (foundTracks==nil || foundTracks.length==0)
                ItunesController::ItunesControllerLogging::error("Unable to find track #{trackInfo}'")
                return nil
            end
            foundTracks.each do | t |
                if (@controller.getTrackDatabaseId(t) == trackInfo.databaseId)                  
                   @controller.removeTracksFromLibrary([t])
                   count=@database.getParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,0).to_i
                   count=count-1
                   @database.setParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,count)
                   if (trackInfo.location!=nil)
                       ItunesController::ItunesControllerLogging::info("Remove track '#{trackInfo.location}' from iTunes library")
                   else
                       ItunesController::ItunesControllerLogging::info("Remove track with databaseId '#{trackInfo.databaseId}' from iTunes library")
                   end
                   @database.removeTrack(trackInfo)
                end
            end            
        end

        def updateTrack(path)
            trackInfo=@database.getTrack(path)
            if (trackInfo==nil)
                ItunesController::ItunesControllerLogging::debug("Unable to find track with path: "+path)
                return nil
            end
            foundTracks=@controller.searchLibrary(trackInfo.title)
            foundTracks.each do | t |
                if (@controller.getTrackDatabaseId(t) == trackInfo.databaseId)
                   @controller.refreshTracks([t])
                   ItunesController::ItunesControllerLogging::info("Refreshed track  '#{trackInfo.location}' metadata")
                end
            end
        end

        def addTrack(path)            
            ItunesController::ItunesControllerLogging::debug("Adding track #{path}")
            ids=@controller.addFilesToLibrary([path])            
            if (ids.length==1)
                if (@database.getTrackById(ids[0].databaseId)!=nil)
                    ItunesController::ItunesControllerLogging::info("Track '#{path}' all ready in the database with the id #{ids[0].databaseId}")
                    return nil
                end
                track=ids[0]                
                @database.addTrack(track) 
                count=@database.getParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,0).to_i                
                count=count+1
                @database.setParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,count)
                ItunesController::ItunesControllerLogging::debug("added track to DB path='#{path}' count='#{count}'")
                ItunesController::ItunesControllerLogging::info("Added track '#{path}' with id #{ids[0].databaseId}")
                return track
            else
                ItunesController::ItunesControllerLogging::info("Unable to add track #{path}")
                return nil
            end
        end

        # Used to lookup a track from it's path
        # @param path The path of the track
        def getTrack(path)
            ItunesController::ItunesControllerLogging::debug("Looking for track #{path}")
            # Get the track info from the database            
            trackInfo=@database.getTrack(path)
            if (trackInfo==nil)
                ItunesController::ItunesControllerLogging::debug("Unable to find track with path: "+path)
                return nil
            end
            
            ItunesController::ItunesControllerLogging::debug("Found track in the database #{trackInfo.title}")
            foundTracks=@controller.searchLibrary(trackInfo.title)
            tracks=[]
            foundTracks.each do | t |
                if (@controller.getTrackDatabaseId(t) == trackInfo.databaseId)
                    tracks.push(t)
                end
            end                        
            if (tracks.length==1)
                ItunesController::ItunesControllerLogging::debug("Found track in iTunes")
                return tracks[0]
            else
                ItunesController::ItunesControllerLogging::debug("Found #{tracks.length}, so unable to find a exact match")
                return nil
            end
        end

        def trackInLibrary?(path)
            trackInfo=@database.getTrack(path)
            return (trackInfo!=nil)
        end

        def cacheTracks(force=false, stream=nil)
            if (force || needsRecacheTracks())
                ItunesController::ItunesControllerLogging::info("Caching tracks...")
                if (stream!=nil)
                     stream.puts("Caching tracks...")
                end
                @database.removeTracks()
                @database.setParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,0)
                count = @controller.getTrackCount()
                size=@controller.getTracks() { |t,count,size,dead|
                    if (dead)
                        ItunesController::ItunesControllerLogging::warn("Found dead track with databaseID #{t.databaseId}")
                        if (stream!=nil)
                             stream.puts("Found dead track with databaseID #{t.databaseId}")
                        end
                            
                        @database.addDeadTrack(t)
                    else
                        @database.addTrack(t)
                    end                    
                    if (count % 150 == 0)
                        ItunesController::ItunesControllerLogging::info("Cached tracks #{count}/#{size}")
                        if (stream!=nil)
                             stream.puts("Cached tracks #{count}/#{size}")                             
                        end
                    end
                }        
                @database.setParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,count)        
                ItunesController::ItunesControllerLogging::info("Cached tracks #{size}/#{size}")
                if (stream!=nil)
                     stream.puts("Cached tracks #{size}/#{size}")
                end                
                return true
            else
                ItunesController::ItunesControllerLogging::debug("Track cache uptodate")
                if (stream!=nil)
                     stream.puts("Track cache uptodate")
                end
            end
            return false
        end
        
        def getCachedTracks() 
           return @database.getTracks() 
        end

        def findDeadTracks()
            return @database.getDeadTracks()
        end

        def removeDeadTracks()
            count=0
            deadTracks=findDeadTracks()
            deadTracks.each do | track |
                removeTrackByInfo(track)
                count+=1
            end
            return count
        end

        def getItunesVersion
            return @controller.version
        end

        def close()
            @database.close()
        end
        
        def getLibraryTrackCount()
            return @controller.getTrackCount()
        end
    
        def needsRecacheTracks()
            # TODO better checks for changes between the cache and iTunes
            count=@controller.getTrackCount()
            cacheCount=@database.getParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,0).to_i
            if (count!=cacheCount)
                ItunesController::ItunesControllerLogging::debug("Need to recache tracks. iTunes has #{count} and cache has #{cacheCount}.")
                return true
            end
            return false
        end
        
        def getDatabase()
            return @database
        end    
    end

end

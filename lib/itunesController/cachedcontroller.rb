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

require 'itunesController/logging'
require 'itunesController/itunescontroller'
require 'itunesController/itunescontroller_factory'
require 'itunesController/database'
require 'itunesController/track'

module ItunesController

    class CachedController

        def initialize(controller=ItunesController::ITunesControllerFactory::createController(),dbPath=nil)
            @controller = controller
            @database = ItunesController::Database.new(@controller,dbPath)
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
            foundTracks=@controller.searchLibrary(trackInfo.title)
            if (foundTracks==nil || foundTracks.length==0)
                ItunesController::ItunesControllerLogging::error("Unable to find track with path '#{path}' and title '#{trackInfo.title}'")
                return nil
            end
            foundTracks.each do | t |
                if (t.databaseID == trackInfo.databaseId)
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
                if (t.databaseID == trackInfo.databaseId)
                   @controller.refreshTracks([t])
                   ItunesController::ItunesControllerLogging::info("Refreshed track  '#{trackInfo.location}' metadate")
                end
            end
        end

        def addTrack(path)
            ids=@controller.addFilesToLibrary([path])
            if (ids.length==1)
                if (@database.getTrackById(ids[0].databaseId)!=nil)
                    ItunesController::ItunesControllerLogging::info("Track '#{path}' allready in the database with the id #{ids[0].databaseId}")
                    return nil
                end
                track=ids[0]
                @database.addTrack(track) 
                count=@database.getParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,0).to_i
                count=count+1
                @database.setParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,count)
                ItunesController::ItunesControllerLogging::info("Added track '#{path}' with id #{ids[0].databaseId}")
                return track
            else
                ItunesController::ItunesControllerLogging::info("Uable to add track #{path}")
                return nil
            end
        end

        def getTrack(path)
            trackInfo=@database.getTrack(path)
            if (trackInfo==nil)
                ItunesController::ItunesControllerLogging::debug("Unable to find track with path: "+path)
                return nil
            end
            foundTracks=@controller.searchLibrary(trackInfo.title)
            tracks=[]
            foundTracks.each do | t |
                if (t.databaseID == trackInfo.databaseId)
                    tracks.push(t)
                end
            end
            if (tracks.length==1)
                return tracks[0]
            else
                return nil
            end
        end

        def trackInLibrary?(path)
            trackInfo=@database.getTrack(path)
            return (trackInfo!=nil)
        end

        def cacheTracks(force=false)
            if (force || needsRecacheTracks())
                ItunesController::ItunesControllerLogging::info("Caching tracks...")
                @database.removeTracks()
                @database.setParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,@controller.getTrackCount())
                size=@controller.getTracks() { |t,count,size,dead|
                    if (dead)
                        ItunesController::ItunesControllerLogging::warn("Found dead track with databaseID #{t.databaseId}")
                        @database.addDeadTrack(t)
                    else
                        @database.addTrack(t)
                    end
                }
                return true
            else
                ItunesController::ItunesControllerLogging::debug("Tracks uptodate")
            end
            return false
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

    private
        def needsRecacheTracks()
            # TODO better checks for changes between the cache and iTunes
            count=@controller.getTrackCount()
            cacheCount=@database.getParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,0).to_i
            if (count!=cacheCount)
                ItunesController::ItunesControllerLogging::debug("Need to reach tracks. iTunes has #{count} and cache has #{cacheCount}.")
                return true
            end
            return false
        end    
    end

end

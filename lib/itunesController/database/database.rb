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

require 'fileutils'

module ItunesController

    class Database

        PARAM_KEY_EXPECTED_TRACKS=1
        PARAM_KEY_TRACK_COUNT=2

        # The constructor
        def initialize(controller,backend)            
            @controller = controller
            @backend = backend            
            createTables()
        end

        def addDeadTrack(track)
            loc = nil
            if (track.location!=nil)
                loc = track.location.to_s
            end
            
            dead_tracks = @backend.sequel()[:dead_tracks]
            dead_tracks.insert(:databaseId => track.databaseId.to_i, :location => loc,:name =>track.title.to_s)            
        end

        def addTrack(track)
            title = track.title.to_s
            loc = track.location.to_s
            id = track.databaseId.to_i
            ItunesController::ItunesControllerLogging::debug("Adding track to database with id=#{id}, title='#{title}' and location='#{loc}'")
            
            tracks = @backend.sequel()[:tracks]
            if (tracks.where(:location => loc).count()>0)
                ItunesController::ItunesControllerLogging::warn("Duplicate track reference detected with databaseId #{id}, title '#{title}' and location '#{loc}'")
                @backend.sequel()[:dupe_tracks].insert(:databaseId => id, :location => loc,:name =>title)
            else
                tracks.insert(:databaseId => id, :location => loc,:name =>title)
            end                       
        end

        def removeTrack(track)
            databaseId = track.databaseId.to_i
            ItunesController::ItunesControllerLogging::debug("Removing track from database with id=#{databaseId}'")
            @backend.sequel()[:tracks].where(:databaseId=>databaseId).delete()
            @backend.sequel()[:dead_tracks].where(:databaseId=>databaseId).delete()
            @backend.sequel()[:dupe_tracks].where(:databaseId=>databaseId).delete()            
        end

        def removeTracks()
            ItunesController::ItunesControllerLogging::debug("Removing all references to tracks in cache...")
            ItunesController::ItunesControllerLogging::debug("Removing tracks...")
            @backend.sequel()[:tracks].delete()            
            ItunesController::ItunesControllerLogging::debug("Removing dead_tracks...")
            @backend.sequel()[:dead_tracks].delete()            
            ItunesController::ItunesControllerLogging::debug("Removing dupe_tracks...")
            @backend.sequel()[:dupe_tracks].delete()            
            ItunesController::ItunesControllerLogging::debug("Tracks references removed from cache")
        end

        def setParam(key,value)
            params = @backend.sequel()[:params]
            params.where(:key=>key).delete()
            params.insert(:key => key, :value => value)
        end

        def getParam(key,default)
            params=@backend.sequel()[:params]
            result = params.first(:key=>key)
            if (result != nil)
                return result[:value]
            end
                     
            return default
        end

        def getTrack(path)
            tracks=@backend.sequel()[:tracks]
            result = tracks.first(:location=>path)
            if (result != nil)
                return ItunesController::Track.new(result[:location],result[:databaseId].to_i,result[:name])
            end            
            return nil
        end

        def getDeadTracks()
            result=[]             
            dead_tracks=@backend.sequel()[:dead_tracks]
            dead_tracks.each do | track |
                result.push(ItunesController::Track.new(track[:location],track[:databaseId].to_i,track[:name]))
            end              
            return result
        end        
        
        def getTracks()
            result=[]             
            dead_tracks=@backend.sequel()[:tracks]
            dead_tracks.each do | track |
                result.push(ItunesController::Track.new(track[:location],track[:databaseId].to_i,track[:name]))
            end              
            return result            
        end

        def getTrackById(id)
            result = @backend.sequel()[:tracks].where(:databaseId=>id)
            result = result.first()
            if (result!=nil)
                return ItunesController::Track.new(result[:location],result[:database_id].to_i,result[:name])
            end           
            return nil
        end

        def close()
            @backend.close()
        end

        def getTrackCount()
            return @backend.sequel()[:tracks].count
        end
        
        def getDeadTrackCount()
            return @backend.sequel()[:dead_tracks].count
        end               
        
        def getDupilicateTrackCount()
            return @backend.sequel()[:dupe_tracks].count
        end

     private
        def createTables()
            ItunesController::ItunesControllerLogging::debug("Database migrations start")            
            @backend.createTables()
            ItunesController::ItunesControllerLogging::debug("Database migrations finish")            
        end       
    end
end


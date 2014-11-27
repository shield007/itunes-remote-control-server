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


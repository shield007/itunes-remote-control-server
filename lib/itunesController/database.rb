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

require 'rubygems'
require 'sqlite3'
require 'etc'
require 'fileutils'

module ItunesController

    class Database

        PARAM_KEY_EXPECTED_TRACKS=1
        PARAM_KEY_TRACK_COUNT=2

        # The constructor
        def initialize(controller,dbPath=nil)
            @controller = controller
            if (dbPath==nil)
                dbPath="#{Etc.getpwuid.dir}/.itunesController/database.db"
            end
            if (!File.directory?(File.dirname(dbPath)))
                FileUtils::mkdir_p(File.dirname(dbPath))
            end
            @db=SQLite3::Database.new( dbPath )

            createTables()

        end

        def addDeadTrack(track)
            stmt = @db.prepare("insert into dead_tracks(databaseId,location,name) values(?,?,?)")
            id=track.databaseId.to_i
            title=track.title.to_s
            loc = nil
            if (track.location!=nil)
                loc = track.location.to_s
            end
            stmt.execute(id,loc,title)
        end

        def addTrack(track)
            stmt = @db.prepare("insert into tracks(databaseId,location,name) values(?,?,?)")
            id=track.databaseId.to_i
            title=track.title.to_s
            loc=track.location.to_s
            #ItunesController::ItunesControllerLogging::debug("Adding track to database with id=#{id}, title='#{title}' and location='#{loc}'")
            begin  
                stmt.execute(id,loc,title)
            rescue SQLite3::ConstraintException
                stmt2 = @db.prepare("select * from tracks where location = ?")
                rows=stmt2.execute(loc) 
                if (rows.next!=nil)
                    ItunesController::ItunesControllerLogging::warn("Duplicate track reference detected with databaseId #{id}, title '#{title}' and location '#{loc}'")
                    stmt3 = @db.prepare("insert into dupe_tracks(databaseId,location,name) values(?,?,?)")
                    stmt3.execute(id,loc,title)
                else
                    ItunesController::ItunesControllerLogging::warn("Unable to add track to database with #{id}, title '#{title}' and location '#{loc}'")
                end
            end
        end

        def removeTrack(track)
            ItunesController::ItunesControllerLogging::debug("Removing track from database with id=#{track.databaseId.to_i}'")
            stmt = @db.prepare("delete from tracks where databaseId=?")
            stmt.execute(track.databaseId.to_i)
            stmt = @db.prepare("delete from dead_tracks where databaseId=?")
            stmt.execute(track.databaseId.to_i)
            stmt = @db.prepare("delete from dupe_tracks where databaseId=?")
            stmt.execute(track.databaseId.to_i)
        end

        def removeTracks()
            ItunesController::ItunesControllerLogging::debug("Removing all tracks")
            @db.execute("delete from tracks")
            @db.execute("delete from dead_tracks")
            @db.execute("delete from dupe_tracks")
        end

        def setParam(key,value)
            stmt = @db.prepare("delete from params where key=?")
            stmt.execute key
            stmt = @db.prepare("insert into params(key,value) values(?,?)")
            stmt.execute key,value
        end

        def getParam(key,default)
            stmt=@db.prepare("select value from params where key = ?")
            rows = stmt.execute(key)
            row=rows.next
            if (row!=nil)
                return row[0]
            end

            return default
        end

        def getTrack(path)
            stmt=@db.prepare("select databaseId,location,name from tracks where location=?")
            rows = stmt.execute(path)
            row=rows.next
            if (row!=nil)
                return ItunesController::Track.new(row[1],row[0].to_i,row[2])
            end
            return nil
        end

        def getDeadTracks()
            result=[]
            stmt=@db.prepare("select databaseId,location,name from dead_tracks")
            rows = stmt.execute()
            while ((row = rows.next)!=nil)
                result.push(ItunesController::Track.new(row[1],row[0].to_i,row[2]))
            end
            return result
        end

        def getTrackById(id)
            stmt=@db.prepare("select databaseId,location,name from tracks where databaseId=?")
            rows = stmt.execute(id)
            row=rows.next
            if (row!=nil)
                return ItunesController::Track.new(row[1],row[0].to_i,row[2])
            end
            return nil
        end

        def close()
            @db.close()
        end

        def getTrackCount()
            return @db.execute("select count(*) from tracks")
        end

     private
        def createTables()
            @db.execute("create table if not exists tracks ( databaseId INTEGER PRIMARY KEY, "+
                                                            "location TEXT NOT NULL, "+
                                                            "name TEXT NOT NULL) ")

            @db.execute("create table if not exists dead_tracks ( databaseId INTEGER NOT NULL, "+
                                                                 "location TEXT, "+
                                                                 "name TEXT NOT NULL) ")

            @db.execute("create table if not exists dupe_tracks ( databaseId INTEGER NOT NULL, "+
                                                                 "location TEXT, "+
                                                                 "name TEXT NOT NULL) ")

            @db.execute("create unique index if not exists 'loction_index' on tracks (location)")
            
            @db.execute("create table if not exists params ( key INTEGER PRIMARY KEY, "+
                                                             "value TEXT NOT NULL) ")
        end
    end
end


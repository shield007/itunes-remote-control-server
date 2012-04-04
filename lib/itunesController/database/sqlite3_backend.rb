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
require 'itunesController/database/backend'

require 'rubygems'
require 'sqlite3'
require 'etc'

module ItunesController

    class SQLite3DatabaseBackend < DatabaseBackend                
        
        def initialize(dbPath=nil)
            if (dbPath==nil)
                dbPath="#{Etc.getpwuid.dir}/.itunesController/database.db"
            end
            if (!File.directory?(File.dirname(dbPath)))
                FileUtils::mkdir_p(File.dirname(dbPath))
            end
            ItunesController::ItunesControllerLogging::info("Database path #{dbPath}")
            @db=SQLite3::Database.new( dbPath )
        end
        
        def prepare(sql)
           return @db.prepare(sql)         
        end
        
        def execute(sql)
            return @db.execute(sql)
        end
        
        def close()
            @db.close()
        end
    end
end
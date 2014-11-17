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
require 'timeout'
require 'itunesController/platform'

require 'rubygems'
require 'sequel'

module ItunesController

    class SequelDatabaseBackend                 
        
        def initialize(connectionString=nil)
            if (connectionString==nil)
                dbPath=ItunesController::Platform::getUserHomeDir()+"/.itunesController/database_2.db"
                              
                if (!File.directory?(File.dirname(dbPath)))
                    FileUtils::mkdir_p(File.dirname(dbPath))
                end
                ItunesController::ItunesControllerLogging::info("Database path #{dbPath}")
                @connectionString = "sqlite://#{dbPath}"
                
            else
                @connectionString = connectionString
            end              
            ItunesController::ItunesControllerLogging::debug("Connecting to #{@connectionString}...")
            begin                
                @db=Sequel.connect(@connectionString,:test=>true,:single_threaded=>true)                               
            rescue => e                 
                ItunesController::ItunesControllerLogging::error("Unable to connect to database with connection: #{@connectionString}")
                raise
            end
                        
            ItunesController::ItunesControllerLogging::debug("Connected")
        end
        
        def version()
            return @db.get{server_version{}}
        end
        
        def sequel()
            return @db 
        end
        
        def createTables()
            Sequel.extension :migration, :core_extensions
            Sequel::Migrator.run(@db, File.dirname(__FILE__)+"/migrations")
        end
        
        def close()
            @db.disconnect()
        end
    end
end

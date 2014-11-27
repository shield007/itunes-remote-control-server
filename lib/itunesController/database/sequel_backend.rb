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
require 'timeout'
require 'itunesController/platform'

require 'rubygems'
require 'sequel'
require 'itunesController/debug'

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
            ItunesController::ItunesControllerLogging::debug("Connecting to '#{@connectionString}'...")
            begin                
                @db=Sequel.connect(@connectionString,:test=>true,:single_threaded=>true)  
            rescue Sequel::AdapterNotFound
                ItunesController::ItunesControllerLogging::error("Unable to load database adapter for connection string: '#{@connectionString}'")                
                raise                                           
            rescue => e                                
                ItunesController::ItunesControllerLogging::error("Unable to connect to database with connection: '#{@connectionString}'")
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

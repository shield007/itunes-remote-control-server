require 'test/unit'
require 'itunesController/database/sequel_backend'
require 'itunesController/database/database'
require 'itunesController/track'

class DatabaseTest < Test::Unit::TestCase 
    
    def this_method
       caller[0][/`([^']*)'/, 1]
    end
    
    def test_DuplicateFiles
        puts("\n-- Test Start: #{this_method()}")
                
        dbBackend = ItunesController::SequelDatabaseBackend.new("sqlite:/")            
        db = ItunesController::Database.new(nil,dbBackend)
        begin    
            db.addTrack(ItunesController::Track.new('/Shows/Seasn 1/S01E01 - Blah.avi',1,"Blah"))
            db.addTrack(ItunesController::Track.new('/Shows/Seasn 1/S01E01 - Blah.avi',2,"Blah"))
                
            # TODO Check that the dupe tracks are in the DB and the normal track
        ensure
            db.close()
        end
        
        puts("--Test Finish:#{this_method()}")
    end
end
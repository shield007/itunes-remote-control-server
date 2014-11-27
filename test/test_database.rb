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

require 'simplecov'
SimpleCov.start

require 'test/unit'
require 'itunesController/database/sequel_backend'
require 'itunesController/database/database'
require 'itunesController/track/track'

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
                
            assert_equal(db.getDeadTrackCount(),0)
            assert_equal(db.getTrackCount(),1)
            assert_equal(db.getDupilicateTrackCount(),1)            
        ensure
            db.close()
        end
        
        puts("--Test Finish:#{this_method()}")
    end
end
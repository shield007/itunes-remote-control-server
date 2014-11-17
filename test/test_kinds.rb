require 'test/unit'
require 'itunesController/kinds'

class KindTest < Test::Unit::TestCase 
    
    def this_method
       caller[0][/`([^']*)'/, 1]
    end
    
    def test_VideoKind
        puts("\n-- Test Start: #{this_method()}")
                
        assert(ItunesController::VideoKind::fromKind(1).displayName()=="Unknown")
        assert(ItunesController::VideoKind::fromKind(1800630348).displayName()=="Unknown")        
        assert(ItunesController::VideoKind::fromKind(1800630352).displayName()=="")
        assert(ItunesController::VideoKind::fromKind(1800630345).displayName()=="")
        assert(ItunesController::VideoKind::fromKind(1800630362).displayName()=="Music")
        assert(ItunesController::VideoKind::Music.displayName()=="Music")
        
        
        puts("--Test Finish:#{this_method()}")
    end
end
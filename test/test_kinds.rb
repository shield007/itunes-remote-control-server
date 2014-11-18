require 'test/unit'
require 'itunesController/kinds'

class KindTest < Test::Unit::TestCase 
    
    def this_method
       caller[0][/`([^']*)'/, 1]
    end
    
    def test_VideoKind
        puts("\n-- Test Start: #{this_method()}")
                
        assert_equal("Unknown",ItunesController::VideoKind::fromKind(1).displayName())
        assert_equal("TV Show",ItunesController::VideoKind::fromKind(1800823892).displayName())                
        assert_equal("Movie",ItunesController::VideoKind::fromKind(1800823885).displayName())
        assert_equal("Music Video",ItunesController::VideoKind::fromKind(1800823894).displayName())
        assert_equal("None",ItunesController::VideoKind::fromKind(1800302446).displayName())
        
        assert_equal("TV Show",ItunesController::VideoKind::TVShow.displayName())
        assert_equal(1800823892,ItunesController::VideoKind::TVShow.kind())
        assert_equal("Movie",ItunesController::VideoKind::Movie.displayName())
        assert_equal(1800823885,ItunesController::VideoKind::Movie.kind())
        assert_equal("Music Video",ItunesController::VideoKind::MusicVideo.displayName())
        assert_equal(1800823894,ItunesController::VideoKind::MusicVideo.kind())
        assert_equal("None",ItunesController::VideoKind::None.displayName())
        assert_equal(1800302446,ItunesController::VideoKind::None.kind())
        assert_equal("Unknown",ItunesController::VideoKind::Unknown.displayName())        
        assert_equal(-1,ItunesController::VideoKind::Unknown.kind())
                
        puts("--Test Finish:#{this_method()}")
    end
    
    def test_SpecialKind
        puts("\n-- Test Start: #{this_method()}")
        
        assert_equal("Unknown",ItunesController::SpecialKind::fromKind(1).displayName())
        assert_equal("Videos",ItunesController::SpecialKind::fromKind(1800630358).displayName())
        
        assert_equal("Audiobooks",ItunesController::SpecialKind::Audiobooks.displayName())
        assert_equal(1800630337,ItunesController::SpecialKind::Audiobooks.kind())
        assert_equal("Movies",ItunesController::SpecialKind::Movies.displayName())
        assert_equal(1800630345,ItunesController::SpecialKind::Movies.kind())        
        assert_equal("Unknown",ItunesController::SpecialKind::Unknown.displayName())        
        assert_equal(-1,ItunesController::SpecialKind::Unknown.kind())
            
        puts("--Test Finish:#{this_method()}")
    end
    
    def test_SourceKind
        puts("\n-- Test Start: #{this_method()}")
        
        assert_equal("Unknown",ItunesController::SourceKind::fromKind(1).displayName())
        assert_equal("Radio Tuner",ItunesController::SourceKind::fromKind(1800697198).displayName())
        
        assert_equal("Audio CD",ItunesController::SourceKind::AudioCD.displayName())
        assert_equal(1799439172,ItunesController::SourceKind::AudioCD.kind())
        assert_equal("Device",ItunesController::SourceKind::Device.displayName())
        assert_equal(1799644534,ItunesController::SourceKind::Device.kind())        
        assert_equal("Unknown",ItunesController::SourceKind::Unknown.displayName())        
        assert_equal(1800760938,ItunesController::SourceKind::Unknown.kind())
            
        puts("--Test Finish:#{this_method()}")
    end
end
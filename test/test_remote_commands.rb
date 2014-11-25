
require 'base_server_test_case'
require 'itunes-remote-add-files'
require 'itunes-remote-list-tracks'
require 'itunes-remote-track-info'
require 'itunes-remote-server-info'
require 'itunes-remote-check-cache'
require 'tempfile'
require 'stringio'

class RemoteCommandTest < BaseServerTest
    
    def initialize(name)
        super(name)               
    end     
    
    def this_method
       caller[0][/`([^']*)'/, 1]
    end
    
    def setup()           
        setupServer()
        createConfigFile()
        @stdout=StringIO.new("","w+")
        @stderr=StringIO.new("","w+")    
    end
    
    def teardown()
        teardownServer()
        if @configFIle!=nil
            @configFile.delete()
        end
        if @server!=nil
            assert(@server.stopped?)
        end    
    end
    
    def createConfigFile()
        @configFile = Tempfile.new("itunesController.xml")               
        @configFile << "<itunesController port=\"#{@port}\" hostname=\"localhost\" >\n"
        @configFile << "  <users>\n"
        @configFile << "    <user username=\"#{@config.username}\" password=\"#{@config.password}\"/>\n"
        @configFile << "  </users>\n"
        @configFile << "</itunesController>\n"
        @configFile.flush()
    end

    class ExitException < Exception               
        def initialize(code)
            @code = code
        end
        
        def code
            return @code
        end
    end
    
    class DummyExitHandler
        def doExit(code=0)
            raise ExitException.new(code), "Exited with code #{code}"
        end
    end
            
    def test_add_files_help                     
        puts("\n-- Test Start: #{this_method()}")
        begin 
            app = AppAddFiles.new('itunes-remote-add-files.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-h"])
        rescue ExitException => e
            assert(e.code() == 0)
        end                        
        assert(@stderr.string.length() == 0)
        assert(@stdout.string.include?("Usage: itunes-remote-add-files.rb [options] files..."))
        assert(@stdout.string.include?("Specific options:"))
        puts("\n-- Test End: #{this_method()}")            
    end
    
    def test_list_tracks_no_files_added
        puts("\n-- Test Start: #{this_method()}")
        begin        
            app = AppListTracks.new('itunes-remote-list-tracks.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e
            assert(e.code() == 0)
        end          
        assert(@stdout.string.include?("No tracks found"))
        puts("\n-- Test End: #{this_method()}")
    end  
    
    def test_add_files_no_files
        puts("\n-- Test Start: #{this_method()}")
        begin        
            app = AppAddFiles.new('itunes-remote-add-files.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e
            assert(e.code() == 0)
        end                             
        puts("\n-- Test End: #{this_method()}")
    end       
    
    def test_track_info
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = AppAddFiles.new('itunes-remote-add-files.rb',@stdout,@stderr,DummyExitHandler.new())            
            file1 = temp_name('show_episode.m4v','','blah')            
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG',file1])
        rescue ExitException => e
            if e.code() != 0
                puts "==================== STDOUT ========================="
                puts @stdout.string
                puts "==================== STDERR ========================="
                puts @stderr.string
                puts "====================================================="
            end
            assert(e.code() == 0)
        end
        
        begin
            app = TrackInfoListTracks.new("itunes-remote-track-info.rb",@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG',file1])
        rescue ExitException => e
            if e.code() != 0
                puts "==================== STDOUT ========================="
                puts @stdout.string
                puts "==================== STDERR ========================="
                puts @stderr.string
                puts "====================================================="
            end            
            assert(e.code() == 0)
        end        
        
        expectedOutput = ""
        expectedOutput = expectedOutput+"location: #{file1}\n"
        expectedOutput = expectedOutput+"databaseId: 0\n"
        expectedOutput = expectedOutput+"title: Test 0\n\n"                
        
        assert_equal(expectedOutput,@stdout.string)           
        puts("\n-- Test End: #{this_method()}")
    end
    
    def test_track_info_json
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = AppAddFiles.new('itunes-remote-add-files.rb',@stdout,@stderr,DummyExitHandler.new())
            file1 = temp_name('show_episode.m4v','','blah')
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG',file1])
        rescue ExitException => e
            if e.code() != 0
                puts "==================== STDOUT ========================="
                puts @stdout.string
                puts "==================== STDERR ========================="
                puts @stderr.string
                puts "====================================================="
            end
            assert(e.code() == 0)
        end
        
        begin
            app = TrackInfoListTracks.new("itunes-remote-track-info.rb",@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG','--json',file1])
        rescue ExitException => e
            if e.code() != 0
                puts "==================== STDOUT ========================="
                puts @stdout.string
                puts "==================== STDERR ========================="
                puts @stderr.string
                puts "====================================================="
            end            
            assert(e.code() == 0)
        end        
        
        expectedOutput = ""
        expectedOutput = expectedOutput + "[\n"
        expectedOutput = expectedOutput + "  {\n"
        expectedOutput = expectedOutput + "    \"location\": \"#{file1}\",\n"
        expectedOutput = expectedOutput + "    \"databaseId\": 0,\n"
        expectedOutput = expectedOutput + "    \"title\": \"Test 0\"\n"
        expectedOutput = expectedOutput + "  }\n"
        expectedOutput = expectedOutput + "]\n"                       
        
        assert_equal(expectedOutput,@stdout.string)           
        puts("\n-- Test End: #{this_method()}")
    end    
    
    def test_add_files
        puts("\n-- Test Start: #{this_method()}")
        begin        
            app = AppAddFiles.new('itunes-remote-add-files.rb',@stdout,@stderr,DummyExitHandler.new())
                
            file1 = temp_name('show_episode.m4v')
            file2 = temp_name('show_episode_1.m4v')
                          
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG',file1,file2])
        rescue ExitException => e
            if e.code() != 0
                puts "==================== STDOUT ========================="
                puts @stdout.string
                puts "==================== STDERR ========================="
                puts @stderr.string
                puts "====================================================="
            end
            assert(e.code() == 0)
        end          
        
        @server.waitForEmptyJobQueue()                
        begin        
            app = AppListTracks.new('itunes-remote-list-tracks.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e
            assert(e.code() == 0)
        end                                 
                
        assert(@stdout.string.include?("Location: #{file1} - Title: Test 0 - DatabaseId: 0"))
        assert(@stdout.string.include?("Location: #{file2} - Title: Test 1 - DatabaseId: 1"))          
        
        @stdout=StringIO.new("","w+")
                                            
        begin
            app = TrackInfoListTracks.new("itunes-remote-track-info.rb",@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG',file1,file2])
        rescue ExitException => e
            if e.code() != 0
                puts "==================== STDOUT ========================="
                puts @stdout.string
                puts "==================== STDERR ========================="
                puts @stderr.string
                puts "====================================================="
            end            
            assert(e.code() == 0)
        end        
                
        expectedOutput = ""
        expectedOutput = expectedOutput+"location: #{file1}\n"
        expectedOutput = expectedOutput+"databaseId: 0\n"
        expectedOutput = expectedOutput+"title: Test 0\n"
        expectedOutput = expectedOutput+"\n"                
        expectedOutput = expectedOutput+"location: #{file2}\n"
        expectedOutput = expectedOutput+"databaseId: 1\n"
        expectedOutput = expectedOutput+"title: Test 1\n"
        expectedOutput = expectedOutput+"\n"
        
        assert_equal(expectedOutput,@stdout.string)
        
        puts("\n-- Test End: #{this_method()}")                       
    end    
    
    def test_server_info
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = AppServerInfo.new('itunes-remote-server-info.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e
            assert(e.code() == 0)
        end        
        
        assert(@stdout.string.include?("ITunes control server: 0.2.0\nApple iTunes version: Dummy\nCache Dirty: false\nCached Track Count: 0\nCached Dead Track Count: 0\nCached Library Track Count: 0\nLibrary Track Count: 0"))               
        puts("\n-- Test End: #{this_method()}")
    end
    
    def test_server_info_json
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = AppServerInfo.new('itunes-remote-server-info.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path(),'--json'])
        rescue ExitException => e
            assert(e.code() == 0)
        end  
        
        expectedResult = "{\n"
        expectedResult = expectedResult+"  \"ITunes control server\": \"0.2.0\",\n"
        expectedResult = expectedResult+"  \"Apple iTunes version\": \"Dummy\",\n"
        expectedResult = expectedResult+"  \"Cache Dirty\": false,\n"
        expectedResult = expectedResult+"  \"Cached Track Count\": 0,\n"
        expectedResult = expectedResult+"  \"Cached Dead Track Count\": 0,\n"
        expectedResult = expectedResult+"  \"Cached Library Track Count\": 0,\n"
        expectedResult = expectedResult+"  \"Library Track Count\": 0\n"
        expectedResult = expectedResult+"}\n"
        assert_equal(expectedResult,@stdout.string)               
        puts("\n-- Test End: #{this_method()}")
    end
    
    def test_check_cache
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = CheckCacheApp.new("itunes-remote-check-cache.rb",@stdout,@stderr,DummyExitHandler.new())                
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e            
            assert(e.code() == 0)
        end
               
        assert(@stdout.string.include?("Cache is uptodate\n"))        
        
        puts("\n-- Test End: #{this_method()}")
    end
    
    def test_check_cache_regenerate
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = CheckCacheApp.new("itunes-remote-check-cache.rb",@stdout,@stderr,DummyExitHandler.new())                
            app.exec(["-c",@configFile.path(),"--regenerated-cache"])
        rescue ExitException => e            
            assert(e.code() == 0)
        end

        assert(@stdout.string.include?("Cache is dirty, Running update\n"))        
        
        puts("\n-- Test End: #{this_method()}")
    end
end
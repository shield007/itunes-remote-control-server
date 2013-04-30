
require 'base_server_test_case'
require 'itunes-remote-add-files'
require 'itunes-remote-list-tracks'
require 'itunes-remote-track-info'
require 'itunes-remote-server-info'
require 'itunes-remote-check-cache'

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
        assert(@stdout.string.include?("Usage: itunes-remote-add-files.rb [options]"))
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
    
    def test_add_files
        puts("\n-- Test Start: #{this_method()}")
        begin        
            app = AppAddFiles.new('itunes-remote-add-files.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG',"/blah/show_episode.m4v","/blah/show_episode_1.m4v"])
        rescue ExitException => e
            puts @stdout.string
            $stderr.puts @stderr.string
            assert(e.code() == 0)
        end          
        
        @server.waitForEmptyJobQueue()
        
                
        begin        
            app = AppListTracks.new('itunes-remote-list-tracks.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e
            assert(e.code() == 0)
        end                          
                
        assert(@stdout.string.include?("Location: /blah/show_episode.m4v - Title: Test 0 - DatabaseId: 0"))
        assert(@stdout.string.include?("Location: /blah/show_episode_1.m4v - Title: Test 1 - DatabaseId: 1"))
   
        
        @stdout=StringIO.new("","w+")
                                            
        begin
            app = TrackInfoListTracks.new("itunes-remote-track-info.rb",@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path(),'--log_config','DEBUG',"/blah/show_episode.m4v","/blah/show_episode_1.m4v"])
        rescue ExitException => e
            puts @stdout.string
            $stderr.puts @stderr.string            
            assert(e.code() == 0)
        end
        
        assert(@stdout.string.include?("Location: /blah/show_episode.m4v\nTitle: Test 0\nDatabaseId: 0\nLocation: /blah/show_episode_1.m4v\nTitle: Test 1\nDatabaseId: 1"))        
        
        puts("\n-- Test End: #{this_method()}")        
        
    end    
    
    def test_info
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = AppServerInfo.new('itunes-remote-server-info.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e
            assert(e.code() == 0)
        end
        puts @stdout.string
        assert(@stdout.string.include?("ITunes control server : 0.2.0\nApple iTunes version : Dummy\nCache Dirty: false\n"))        
        
        puts("\n-- Test End: #{this_method()}")
    end
    
    def test_aacheck_cache
        puts("\n-- Test Start: #{this_method()}")
        begin
            app = CheckCacheApp.new("itunes-remote-check-cache.rb",@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e            
            assert(e.code() == 0)
        end
               
        assert(@stdout.string.include?("Track cache uptodate\n"))        
        
        puts("\n-- Test End: #{this_method()}")
    end
end
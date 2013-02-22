require 'base_server_test_case'
require 'itunes-remote-add-files'
require 'itunes-remote-list-tracks'

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
        @configFile.delete()
        assert(@server.stopped?)    
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
    
    def test_aalist_files
        puts("\n-- Test Start: #{this_method()}")
        begin        
            app = AppListTracks.new('itunes-remote-list-tracks.rb',@stdout,@stderr,DummyExitHandler.new())
            app.exec(["-c",@configFile.path()])
        rescue ExitException => e
            assert(e.code() == 0)
        end                             
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
            app.exec(["-c",@configFile.path(),"/blah/show_episode.m4v","/blah/show_episode_1.m4v"])
        rescue ExitException => e
            print @stdout.string
            assert(e.code() == 0)
        end              
        print @stdout.string
        print @stderr.string
        puts("\n-- Test End: #{this_method()}")        
    end
    
                  
    
end
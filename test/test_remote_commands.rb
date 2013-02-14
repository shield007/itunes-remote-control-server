require 'base_server_test_case'
require 'itunes-remote-add-files'

require 'stringio'

class RemoteCommandTest < BaseServerTest
    
    def this_method
       caller[0][/`([^']*)'/, 1]
    end
    
    def createConfigFile()
        @configFile = Tempfile.new("itunesController.xml")
        @configFile.open() do | file |            
            file.puts("<itunesController port=\"#{@port}\" hostname=\"localhost\" >")
            file.puts("  <users>")
            file.puts("    <user username=\"#{@config.username}\" password=\"#{@config.password}\"/>")
            file.puts("  </users>")
            file.puts("</itunesController>")
        end
        
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
        setupServer()        
        begin
            createConfigFile()
            stdout=StringIO.new("","w+")
            stderr=StringIO.new("","w+")              
            begin 
                app = AppAddFiles.new('itunes-remote-add-files.rb',stdout,stderr,DummyExitHandler.new())
                app.exec(["-h"])
            rescue ExitException => e
                assert(e.code() == 0)
            end            
            puts "Lines: "+stdout.string            
            assert(stderr.string.length() == 0)
            assert(stdout.string.include?("Usage: itunes-remote-add-files.rb [options]"))
            assert(stdout.string.include?("Specific options:"))            
        ensure
            teardownServer()
            @configFile.delete()
            assert(@server.stopped?)            
        end
        puts("-- Test Finish:#{this_method()}")
    end
    
end
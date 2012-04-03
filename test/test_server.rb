require 'base_server_test_case'
require 'dummy_client'
require 'itunesController/track'

class ServerTest < BaseServerTest
    
    def this_method
       caller[0][/`([^']*)'/, 1]
    end
    
    def test_connect
        puts("\n-- Test Start: #{this_method()}")
        setupServer
        begin
            assert(!@server.stopped?)
#            assert_equal(0,@server.connections.size)
            client=DummyClient.new
            client.connect("localhost",@port)
#            assert_equal(1,@server.connections.size)
            client.disconnect
            # TODO Fix this so when the client disconnects, we spot it
            #            assert_equal(0,@server.connections.size)
        ensure
            teardownServer
            assert(@server.stopped?)
        end
        puts("-- Test Finish:#{this_method()}")
    end

    def test_quit_loggedin
        puts("\n-- Test Start: #{this_method()}")
        setupServer
        begin
            assert(!@server.stopped?)
#            assert_equal(0,@server.connections.size)
            client=DummyClient.new
            client.connect("localhost",@port)
#            assert_equal(1,@server.connections.size)
            client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
            client.sendCommand(ItunesController::CommandName::QUIT,221)
            # TODO Fix this so when the client disconnects, we spot it
            #assert_equal(0,@server.connections.size)
            client.disconnect
        ensure
            teardownServer
            assert(@server.stopped?)
        end
        puts("-- Test Finish:#{this_method()}")
    end

    def test_quit_not_loggedin
        puts("\n-- Test Start: #{this_method()}")
        setupServer
        begin
            assert(!@server.stopped?)
#            assert_equal(0,@server.connections.size)
            client=DummyClient.new
            client.connect("localhost",@port)
#            assert_equal(1,@server.connections.size)
            client.sendCommand(ItunesController::CommandName::QUIT,221)
            # TODO Fix this so when the client disconnects, we spot it
            #assert_equal(0,@server.connections.size)
            client.disconnect
        ensure
            teardownServer
            assert(@server.stopped?)
        end
        puts("--Test Finish:#{this_method()}")
    end

    def test_login
        puts("\n-- Test Start: #{this_method()}")
        setupServer
        begin
            client=DummyClient.new
            client.connect("localhost",@port)
            client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
            client.sendCommand(ItunesController::CommandName::QUIT,221)
            client.disconnect
        ensure
            teardownServer
        end
        puts("--Test Finish:#{this_method()}")
    end

    def test_InvalidLoginDetails
        puts("\n-- Test Start: #{this_method()}")
        setupServer
        begin            
            client=DummyClient.new
            client.connect("localhost",@port)
            begin
                client.login(BaseServerTest::USER,"blah1")
            rescue
            end
            begin
                client.login("balh",BaseServerTest::PASSWORD)
            rescue
            end
            client.disconnect
            assertCommandLog(["getTrackCount() = 0"])            
        ensure
            teardownServer
        end
        puts("--Test Finish:#{this_method()}")
    end

    def test_CommandsDontWorkWhenNotLoggedIn
        puts("\n-- Test Start: #{this_method()}")
        setupServer
        begin
            client=DummyClient.new
            client.connect("localhost",@port)            
            client.sendCommand(ItunesController::CommandName::REMOVEDEADFILES,500)            
            assertCommandLog(["getTrackCount() = 0"])
            client.disconnect
        ensure
            teardownServer
        end
        puts("--Test Finish:#{this_method()}")
    end

    def test_AddFiles
        puts("\n-- Test Start: #{this_method()}")                
        setupServer        
        begin                       
            client=DummyClient.new
            client.connect("localhost",@port)            
            client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
            
            client.sendCommand(ItunesController::CommandName::FILE+":/blah", 220);
            client.sendCommand(ItunesController::CommandName::FILE+":/blah1/shows's/S01E01 - The Episode.m4v", 220);
            client.sendCommand(ItunesController::CommandName::FILE+":/blah/blah2", 220);
            client.sendCommand(ItunesController::CommandName::ADDFILES, 220);
            client.sendCommand(ItunesController::CommandName::HELO, 220);
            
            commandLog = ItunesController::DummyITunesController::getCommandLog()            
            
            assertCommandLog(["getTrackCount() = 0",
                              "addFilesToLibrary(/blah)",
                              "addFilesToLibrary(/blah1/shows's/S01E01 - The Episode.m4v)",
                              "addFilesToLibrary(/blah/blah2)"])      
            client.sendCommand(ItunesController::CommandName::QUIT,221)
            client.disconnect
        ensure
            teardownServer
            assert(@server.stopped?)
        end
        puts("--Test Finish:#{this_method()}")
    end        
    
    def test_RemoveFiles
        puts("\n-- Test Start: #{this_method()}")
        setupServer([ItunesController::Track.new("/blah",1,"Test 1"),
                     ItunesController::Track.new("/blah1/shows's/S01E01 - The Episode.m4v",2,"Test 2"),
                     ItunesController::Track.new("/blah1/blah2",3,"Test 3")])        
        begin   
            Dir.tmpdir do                    
                client=DummyClient.new
                client.connect("localhost",@port)            
                client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)

                files=[Dir.pwd+"/blah",
                       Dir.pwd+"/blah1/shows's/S01E01 - The Episode.m4v",
                       Dir.pwd+"/blah/blah2"]
                files.each do | file |
                    File.open(file, "w") {}
                    client.sendCommand(ItunesController::CommandName::FILE+":"+file, 220);
                end                
                client.sendCommand(ItunesController::CommandName::REMOVEFILES, 220);
                client.sendCommand(ItunesController::CommandName::HELO, 220);
                
                commandLog = ItunesController::DummyITunesController::getCommandLog()
                expected=[]
                expected.push("getTrackCount() = 0")
                files.each do | file |
                    expected.push("addFilesToLibrary("+file+")")
                end               
                files.each do | file |
                    expected.push("removeTracksFromLibrary(Location: '#{file}' - Database ID: 0 - Name: 'Test 0' )")
                end
                assertCommandLog(expected)                                                                    
                client.sendCommand(ItunesController::CommandName::QUIT,221)
                client.disconnect
            end
        ensure
            teardownServer
            assert(@server.stopped?)
        end
        puts("--Test Finish:#{this_method()}")
    end
    
    def test_RefreshFiles
        Dir.tmpdir do
            puts("\n-- Test Start: #{this_method()}")
            tracks = [ItunesController::Track.new(Dir.pwd+"/blah",1,"Test 1"),
                      ItunesController::Track.new(Dir.pwd+"/blah1/shows's/S01E01 - The Episode.m4v",2,"Test 2"),
                      ItunesController::Track.new(Dir.pwd+"/blah1/blah2",3,"Test 3")]
            files=[]
            tracks.each do | t |
                File.open(file, "w") {}
                files.push(t.location)
            end
            setupServer(tracks)
            begin                                
                client=DummyClient.new
                client.connect("localhost",@port)            
                client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)                                
                client.sendCommand(ItunesController::CommandName::REFRESHFILES, 220);
                client.sendCommand(ItunesController::CommandName::HELO, 220);
                
                commandLog = ItunesController::DummyITunesController::getCommandLog()
                assertCommandLog(["getTrackCount() = 0",
                                  "addFilesToLibrary(/blah)",
                                  "addFilesToLibrary(/blah1/shows's/S01E01 - The Episode.m4v)",
                                  "addFilesToLibrary(/blah/blah2)",
                                  "refreshTracks(Location: '/blah' - Database ID: 0 - Name: 'Test 0' )",
                                  "refreshTracks(Location: '/blah1' - Database ID: 1 - Name: 'Test 1' )",            
                                  "refreshTracks(Location: '/blah/blah2' - Database ID: 2 - Name: 'Test 2' )"])            
                
                client.sendCommand(ItunesController::CommandName::QUIT,221)
                client.disconnect            
            ensure
                teardownServer
                assert(@server.stopped?)
            end
            puts("--Test Finish:#{this_method()}")
        end
    end
    
    def test_ClearFiles
       puts("\n-- Test Start: #{this_method()}")
       setupServer
       begin           
           client=DummyClient.new
           client.connect("localhost",@port)            
           client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
           
           client.sendCommand(ItunesController::CommandName::FILE+":/blah", 220);
           client.sendCommand(ItunesController::CommandName::FILE+":/blah1", 220);
           client.sendCommand(ItunesController::CommandName::FILE+":/blah/blah2", 220);
           client.sendCommand(ItunesController::CommandName::CLEARFILES, 220);
           client.sendCommand(ItunesController::CommandName::HELO, 220);
                      
           assertCommandLog(["getTrackCount() = 0"])           
           
           client.sendCommand(ItunesController::CommandName::QUIT,221)
           client.disconnect
       ensure
           teardownServer
           assert(@server.stopped?)
       end
       puts("--Test Finish:#{this_method()}")
   end

   def test_ClearFiles2
       puts("\n-- Test Start: #{this_method()}")
       setupServer
       begin           
           client=DummyClient.new
           client.connect("localhost",@port)            
           client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
           
           client.sendCommand(ItunesController::CommandName::CLEARFILES, 220);
           client.sendCommand(ItunesController::CommandName::HELO, 220);
           
           assertCommandLog(["getTrackCount() = 0"])           
           
           client.sendCommand(ItunesController::CommandName::QUIT,221)
           client.disconnect
       ensure
           teardownServer
           assert(@server.stopped?)
       end
       puts("-- Test Finish:#{this_method()}")
   end
   
   def test_RemoveDeadFiles
       puts("\n-- Test Start: #{this_method()}")
       tracks=[ItunesController::Track.new("/blah",1,"Test 1"),
       ItunesController::Track.new("/blah1/shows's/S01E01 - The Episode.m4v",2,"Test 2"),
       ItunesController::Track.new("/blah1/blah2",3,"Test 3")]
       setupServer(tracks)
       begin
           client=DummyClient.new
           client.connect("localhost",@port)            
           client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
           
           client.sendCommand(ItunesController::CommandName::REMOVEDEADFILES, 220);
           client.sendCommand(ItunesController::CommandName::HELO, 220);
           
           commandLog = ItunesController::DummyITunesController::getCommandLog()                     
           expected=[]
           expected.push("getTrackCount() = 3")
           expected.push("getTrackCount() = 3")
           expected.push("getTracks()")
           tracks.each do | t |           
               expected.push("removeTracksFromLibrary(Location: '#{t.location}' - Database ID: #{t.databaseId} - Name: '#{t.title}' )")
           end
           assertCommandLog(expected)
           client.sendCommand(ItunesController::CommandName::QUIT,221)
           client.disconnect
       ensure
           teardownServer
           assert(@server.stopped?)
       end
       puts("-- Test Finish:#{this_method()}")
   end
   
end
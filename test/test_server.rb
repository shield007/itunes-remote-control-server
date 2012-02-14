require 'base_server_test_case'
require 'dummy_client'

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
            orgSize=ItunesController::DummyITunesController::COMMAND_LOG.size()
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
            assert_equal(orgSize,ItunesController::DummyITunesController::COMMAND_LOG.size());
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
            orgSize=ItunesController::DummyITunesController::COMMAND_LOG.size()
            client.sendCommand(ItunesController::CommandName::REMOVEDEADFILES,500)            
            assert_equal(orgSize,ItunesController::DummyITunesController::COMMAND_LOG.size());
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
            orgSize=ItunesController::DummyITunesController::COMMAND_LOG.size()
            client=DummyClient.new
            client.connect("localhost",@port)            
            client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
            
            client.sendCommand(ItunesController::CommandName::FILE+":/blah", 220);
            client.sendCommand(ItunesController::CommandName::FILE+":/blah1/shows's/S01E01 - The Episode.m4v", 220);
            client.sendCommand(ItunesController::CommandName::FILE+":/blah/blah2", 220);
            client.sendCommand(ItunesController::CommandName::ADDFILES, 220);
            client.sendCommand(ItunesController::CommandName::HELO, 220);
            
            commandLog = ItunesController::DummyITunesController::COMMAND_LOG
            assert_equal(orgSize+4,commandLog.size());            
            assert_equal("addFilesToLibrary(files)",commandLog[orgSize]);
            assert_equal("addFilesToLibrary(/blah)",commandLog[orgSize+1]);
            assert_equal("addFilesToLibrary(/blah1/shows's/S01E01 - The Episode.m4v)",commandLog[orgSize+2]);
            assert_equal("addFilesToLibrary(/blah/blah2)",commandLog[orgSize+3]);
            
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
        setupServer
        begin
            orgSize=ItunesController::DummyITunesController::COMMAND_LOG.size()
            client=DummyClient.new
            client.connect("localhost",@port)            
            client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
            
            client.sendCommand(ItunesController::CommandName::FILE+":/blah", 220);
            client.sendCommand(ItunesController::CommandName::FILE+":/blah1", 220);
            client.sendCommand(ItunesController::CommandName::FILE+":/blah/blah2", 220);
            client.sendCommand(ItunesController::CommandName::REMOVEFILES, 220);
            client.sendCommand(ItunesController::CommandName::HELO, 220);
            
            commandLog = ItunesController::DummyITunesController::COMMAND_LOG
            assert_equal(orgSize+5,commandLog.size());
            assert_equal("findTracksWithLocations(locations)",commandLog[orgSize]);
            assert_equal("removeTracksFromLibrary(tracks)",commandLog[orgSize+1]);
            
            client.sendCommand(ItunesController::CommandName::QUIT,221)
            client.disconnect
        ensure
            teardownServer
            assert(@server.stopped?)
        end
        puts("--Test Finish:#{this_method()}")
    end
    
    def test_ClearFiles
       puts("\n-- Test Start: #{this_method()}")
       setupServer
       begin
           orgSize=ItunesController::DummyITunesController::COMMAND_LOG.size()
           client=DummyClient.new
           client.connect("localhost",@port)            
           client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
           
           client.sendCommand(ItunesController::CommandName::FILE+":/blah", 220);
           client.sendCommand(ItunesController::CommandName::FILE+":/blah1", 220);
           client.sendCommand(ItunesController::CommandName::FILE+":/blah/blah2", 220);
           client.sendCommand(ItunesController::CommandName::CLEARFILES, 220);
           client.sendCommand(ItunesController::CommandName::HELO, 220);
           
           commandLog = ItunesController::DummyITunesController::COMMAND_LOG
           assert_equal(orgSize,commandLog.size());           
           
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
           orgSize=ItunesController::DummyITunesController::COMMAND_LOG.size()
           client=DummyClient.new
           client.connect("localhost",@port)            
           client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
           
           client.sendCommand(ItunesController::CommandName::CLEARFILES, 220);
           client.sendCommand(ItunesController::CommandName::HELO, 220);
           
           commandLog = ItunesController::DummyITunesController::COMMAND_LOG
           assert_equal(orgSize,commandLog.size());           
           
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
       setupServer
       begin
           orgSize=ItunesController::DummyITunesController::COMMAND_LOG.size()
           client=DummyClient.new
           client.connect("localhost",@port)            
           client.login(BaseServerTest::USER,BaseServerTest::PASSWORD)
           
           client.sendCommand(ItunesController::CommandName::REMOVEDEADFILES, 220);
           client.sendCommand(ItunesController::CommandName::HELO, 220);
           
           commandLog = ItunesController::DummyITunesController::COMMAND_LOG
           assert_equal(orgSize+2,commandLog.size());
           assert_equal("findDeadTracks()",commandLog[orgSize]);
           assert_equal("removeTracksFromLibrary(tracks)",commandLog[orgSize+1]);
           
           client.sendCommand(ItunesController::CommandName::QUIT,221)
           client.disconnect
       ensure
           teardownServer
           assert(@server.stopped?)
       end
       puts("-- Test Finish:#{this_method()}")
   end
   
end
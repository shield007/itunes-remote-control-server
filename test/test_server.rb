require 'base_server_test'
require 'dummy_client'

class ServerTest < BaseServerTest
    
    def test_connect                
        setupServer            
        begin
            assert(!@server.stopped?)
            assert_equal(0,@server.connections.size)    
            client=DummyClient.new                  
            client.connect("localhost",@port)                
            assert_equal(1,@server.connections.size)       
            client.disconnect
            # TODO Fix this so when the client disconnects, we spot it
#            assert_equal(0,@server.connections.size)
        ensure    
            teardownServer
            assert(@server.stopped?)
        end
    end
    
    def test_quit                
            setupServer            
            begin
                assert(!@server.stopped?)
                assert_equal(0,@server.connections.size)    
                client=DummyClient.new                  
                client.connect("localhost",@port)                
                assert_equal(1,@server.connections.size)
                client.sendCommand(ItunesController::CommandName::QUIT,221)
                assert_equal(0,@server.connections.size)       
                client.disconnect                
            ensure    
                teardownServer
                assert(@server.stopped?)
            end
        end
    
    def test_login
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
    end
end
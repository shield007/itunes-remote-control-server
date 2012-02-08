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
#            assert_equal(0,@server.connections.size)
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
            client.disconnect
        ensure    
            teardownServer
        end
    end
end
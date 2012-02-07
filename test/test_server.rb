require 'base_server_test'

class ServerTest < BaseServerTest
    
    def test_connect
        setupServer    
        begin
            
        ensure    
            teardownServer
        end
    end
end
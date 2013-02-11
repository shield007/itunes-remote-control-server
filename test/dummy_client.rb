
require 'net/telnet'

require 'itunesController/controllserver'

class DummyClient
    
    DEFAULT_TIMEOUT=40    
    
    def connect(hostname,port)
        @client=Net::Telnet::new('Host' => hostname,
                                 'Port' => port,
                                 'Telnetmode' => false)        
        @client.waitfor('String'=>"001 hello")
        sendCommand("HELO",220)
    end
    
   
    def disconnect
        @client.close
    end
    
    def login(username,password)
        sendCommand(ItunesController::CommandName::LOGIN+":"+username,222); 
        sendCommand(ItunesController::CommandName::PASSWORD+":"+password,223); 
    end
    
    def sendCommand(cmd, expectedCode,timeout=DummyClient::DEFAULT_TIMEOUT)
        @client.cmd(cmd) do | response |            
            if (response!=nil)            
                response.each_line do | line |                                
                    if ( line =~ /(\d+).*/)                    
                        code=$1
                        if (code.to_i==expectedCode)                    
                            return;
                        end
                    end
                end
            end         
            raise "Did not receive expected response from server"   
        end        
    end
        
end

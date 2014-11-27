#
# The MIT License (MIT)
# 
# Copyright (c) 2011-2014 John-Paul Stanford <dev@stanwood.org.uk>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011-2014  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: The MIT License (MIT) <http://opensource.org/licenses/MIT>
#

require 'net/telnet'

require 'itunesController/server/server'

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

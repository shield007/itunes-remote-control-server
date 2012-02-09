require 'test/unit'
require 'socket'
require 'timeout'

require 'itunesController/config'
require 'itunesController/dummy_itunescontroller'
require 'itunesController/controllserver'

class BaseServerTest < Test::Unit::TestCase 
    
    USER="test"
    PASSWORD="testpass"
    MIN_PORT_NUMBER = 5000
    MAX_PORT_NUMBER = 9000
    
    attr_accessor :server,:port
    
    def portOpen?(ip, port, seconds=1)
      Timeout::timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          false
        end
      end
    rescue Timeout::Error
      false
    end
    
    def findAvaliablePort
        port=BaseServerTest::MIN_PORT_NUMBER   
        while (port < BaseServerTest::MAX_PORT_NUMBER )
            if !portOpen?("127.0.0.1",port)
                return port
            end        
            port+=1        
        end   
        return -1
    end
    
    def setupServer
        ItunesController::DummyITunesController::COMMAND_LOG.take_while {
            | el |
        }
        
        
        controller = ItunesController::DummyITunesController.new
        config=ItunesController::ServerConfig.new
        config.port = findAvaliablePort
        @port = config.port
        config.username = BaseServerTest::USER
        config.password = BaseServerTest::PASSWORD
        @server=ItunesController::ITunesControlServer.new(config,config.port,controller)
        @server.start
    end
    
    def teardownServer
        @server.stop
        while !@server.stopped?
        end
        @server.join
    end
        
end
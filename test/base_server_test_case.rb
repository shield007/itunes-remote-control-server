

require 'tempfile'
require 'test/unit'
require 'socket'
require 'timeout'

require 'itunesController/platform'
require 'itunesController/config'
require 'itunesController/itunes/dummy_itunescontroller'
require 'itunesController/server/server'
require 'itunesController/cachedcontroller'
require 'itunesController/controller_creator'

require 'itunesController/database/sequel_backend'

class DummyControllerCreator < ItunesController::ControllerCreator
    
    def initialize(controller)
        @controller = controller
    end
    
    def createController(connectionString)
        return @controller
    end
end

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
    
    def setupServer(tracks=nil)
        ItunesController::DummyITunesController::resetCommandLog()
        ItunesController::DummyITunesController::resetTracks()        
        if (tracks!=nil)
            tracks.each do | track |
                ItunesController::DummyITunesController::forceAddTrack(track)
            end 
        end        
        
        ItunesController::DummyITunesController::getCommandLog().take_while {
            | el |
        }
        #@dbFile = Tempfile.new('dummyDatabase.db')
        itunes = ItunesController::DummyITunesController.new        
        dbBackend = ItunesController::SequelDatabaseBackend.new("sqlite:/")
        controller = ItunesController::CachedController.new(itunes,dbBackend)        
        @config=ItunesController::ServerConfig.new
        @config.port = findAvaliablePort
        @port = @config.port
        @config.username = BaseServerTest::USER
        @config.password = BaseServerTest::PASSWORD
        @server=ItunesController::ITunesRestServer.new(@config,DummyControllerCreator.new(controller))        
    end
    
    def teardownServer
        if @server!=nil
            @server.stop
            while !@server.stopped?
            end
            @server.join
        end
        if @dbFile!=nil
            @dbFile.unlink
        end
    end

    def test_dummy
    end
    
    def assertCommandLog(expected)
        sleep(2)
        @server.waitForEmptyJobQueue()
        actual=ItunesController::DummyITunesController::getCommandLog()
        error=false
        if (expected.size()!=actual.size()) 
            puts("Worng number of command log entries")
            error = true
        end
            
        
        for i in (0..expected.size())
            if (expected[i]!=actual[i])
                error=true
            end
        end
        if (error)
            puts("Command log did not match expected.")
            puts("Expected:")
            expected.each do | line |
                puts("  "+line)
            end
            puts("Actual:")
            actual.each do | line |
                puts("  "+line)
            end
            raise("Command log did not match expected.")
        end
    end
        
end

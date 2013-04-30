require 'itunesController/logging'
require 'itunesController/version'
require 'itunesController/config'
require 'itunesController/controllserver'
require 'itunesController/codes'

require 'rubygems'
require 'optparse'
require 'net/telnet'
require 'json'

module ItunesController        
    class RemoteApplication
        
        class ExitHandler
            def doExit(code=0)
                exit(code)
            end
        end
        
        def initialize(appName,stdout=$stdout,stderr=$stdout,exitHandler=ExitHandler.new())
            @appName = appName
            @options = {}
            @options[:logFile] = nil
            @stdout = stdout
            @stderr = stderr
            @exitHandler = exitHandler
        end
    
        def genericOptionDescription()
            result=[]
            result.push("Specific options:")
            result.push("    -c, --config FILE                The configuration file")
            result.push("    -f, --log_file FILE              Optional paramter used to log messages to")
            result.push("    -l, --log_config LEVEL           Optional paramter used to log level [DEBUG|INFO|WARN|ERROR]")               
            result.push("    -v, --version                    Display version of the application")
            result.push("    -h, --help                       Display this screen")
            return result.join("\n")
        end
    
        # Used to display the command line useage
        def displayUsage()
            @stdout.puts("Usage: "+@appName+" [options]")
            @stdout.puts("")
            @stdout.puts(genericOptionDescription())
        end        
    
        # Used to display a error message and the command line usesage
        # @param [String] message The error message
        def usageError(message)
            @stderr.puts "ERROR: "+message
            displayUsage()
            @exitHandler.doExit(1)
        end
    
        # Used to check the command line options are valid
        def checkOptions
            if (@options[:config]==nil) 
                                           
                usageError("No configuration file specified. Use --config option.")
            end
            checkAppOptions        
        end
    
        # Parse the command line options
        def parseOptions(args)
            optparse = OptionParser.new do|opts|
                opts.banner = "Usage: "+@appName+" [options]"
                opts.separator ""
                opts.separator "Specific options:"
                opts.on('-c','--config FILE','The configuration file') do |value|
                    @options[:config] = value
                end
                opts.on('-f','--log_file FILE','Optional paramter used to log messages to') do |value|
                    @options[:logFile] = value
                    ItunesController::ItunesControllerLogging::setLogFile(@options[:logFile])
                end
                opts.on('-l','--log_config LEVEL','Optional paramter used to log level [DEBUG|INFO|WARN|ERROR]') do |value|
                    @options[:logConfig] = value
                    ItunesController::ItunesControllerLogging::setLogLevelFromString(@options[:logConfig])
                end
                parseAppOptions(opts)
    
                opts.on_tail( '-v', '--version', 'Display version of the application' ) do
                    @stdout.puts "#{@appName} "+ItunesController::VERSION
                    @stdout.puts "Copyright (C) 2012 John-Paul Stanford"
                    @stdout.puts "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
                    @stdout.puts "This is free software: you are free to change and redistribute it."
                    @stdout.puts "There is NO WARRANTY, to the extent permitted by law."
                    @stdout.puts ""
                    @stdout.puts "Authors: John-Paul Stanford <dev@stanwood.org.uk>"
                    @stdout.puts "Website: http://code.google.com/p/itunes-remote-control-server/"
                end
                opts.on_tail( '-h', '--help', 'Display this screen' ) do
                    @stdout.puts opts
                    @exitHandler.doExit(0)
                end
                end
            optparse.parse!(args)
            checkOptions()
        end   
        
    
        def getOptions()
            return @options
        end
    
        def parseAppOptions(opts)
        end
    
        def checkAppOptions()
        end               
        
        # Create a connection to the remote server
        def connect()
            @client=Net::Telnet::new('Host' => @config.hostname,
                                     'Port' => @config.port,
                                     'Telnetmode' => false)
            waitFor(001)
            ItunesController::ItunesControllerLogging::info("Connected")
            
        end
        
        # Login to the remote server
        def login()
            sendCommand(ItunesController::CommandName::LOGIN+":"+@config.username,ItunesController::Code::PasswordPrompt.to_i); 
            sendCommand(ItunesController::CommandName::PASSWORD+":"+@config.password,ItunesController::Code::Authenticated.to_i);
            ItunesController::ItunesControllerLogging::info("Logged in") 
        end
        
        # Check the remote server is responding
        def ping()
            sendCommand("#{ItunesController::CommandName::HELO}",ItunesController::Code::OK.to_i)
        end
        
        # Terminate connection to the remote server
        def quit()
            sendCommand(ItunesController::CommandName::QUIT,221)
            ItunesController::ItunesControllerLogging::info("Terminated connection")
        end
        
        # Notify the remote server of a file that an action is to be performed on
        # @param file The file
        def file(file)
            sendCommand(ItunesController::CommandName::FILE+":#{file}",ItunesController::Code::OK.to_i)
        end
        
        def addFiles()
            sendCommand(ItunesController::CommandName::ADDFILES,ItunesController::Code::OK.to_i)       
        end
        
        def refreshFiles()
            sendCommand(ItunesController::CommandName::REFRESHFILES,ItunesController::Code::OK.to_i)
        end
        
        def removeFiles()
            sendCommand(ItunesController::CommandName::REMOVEFILES,ItunesController::Code::OK.to_i)
        end
        
        def serverInfo()
            result=sendCommand(ItunesController::CommandName::VERSION,ItunesController::Code::OK.to_i)
            result = JSON.parse(result)           
            @stdout.puts("ITunes control server : #{result['server']}")
            @stdout.puts("Apple iTunes version : #{result['iTunes']}")
            result=sendCommand(ItunesController::CommandName::SERVERINFO,ItunesController::Code::OK.to_i)
            result = JSON.parse(result)
            @stdout.puts("Cache Dirty: #{result['cacheDirty']}")
            @stdout.puts("Cached Track Count: #{result['cachedTrackCount']}")
            @stdout.puts("Cached Dead Track Count: #{result['cachedDeadTrackCount']}")
            @stdout.puts("Cached Library Track Count: #{result['cachedLibraryTrackCount']}")
            @stdout.puts("Library Track Count: #{result['libraryTrackCount']}")
        end
        
        def listTracks()
            result=sendCommand(ItunesController::CommandName::LISTTRACKS,ItunesController::Code::OK.to_i)
            result = JSON.parse(result)
            tracks = result['tracks']
            if (tracks==nil or tracks.length()==0)
                @stdout.puts("No tracks found")
            else
                tracks.each do | track |
                    @stdout.puts("Location: #{track['location']} - Title: #{track['title']} - DatabaseId: #{track['databaseId']}")
                end
                
            end            
        end
        
        def infoTrackByPath(path)
            result=sendCommand(ItunesController::CommandName::TRACKINFO+':path:'+path,ItunesController::Code::OK.to_i)            
            result = JSON.parse(result)
            @stdout.puts("Location: #{result['location']}")
            @stdout.puts("Title: #{result['title']}")
            @stdout.puts("DatabaseId: #{result['databaseId']}")
        end
        
        def checkCache()
            sendCommand(ItunesController::CommandName::CHECKCACHE,ItunesController::Code::OK.to_i,@stdout)            
        end
        
        def waitFor(expected)
            @client.waitfor(/\n/) do |response|
                if (response!=nil)                               
                    response.each_line do | line |                                                       
                        if ( line =~ /(\d+).*/)                    
                            code=$1                            
                            if (code.to_i==expected)                    
                                return;
                            end
                        end
                    end
                end
            end
        end
           
        # Used to send a command to the server and wait for a response. 
        # @param cmd The command to send
        # @param expectedCode The code to wait for
        # @return the command response       
        def sendCommand(cmd, expectedCode,stream = nil)
            if (cmd =~ /PASSWORD:(.*)/)
                cleanedCmd = "PASSWORD:<hidden>"
                ItunesController::ItunesControllerLogging::debug("Send command #{cleanedCmd} and wait for #{expectedCode}")
            else
                ItunesController::ItunesControllerLogging::debug("Send command #{cmd} and wait for #{expectedCode}")
            end            
            
            result = ""
            @client.cmd(cmd) do | response |            
                if (response!=nil)            
                    response.each_line do | line |                                                   
                        if ( line =~ /(\d+)(.*)/)                   
                            code=$1.to_i                                                        
                            if (code==expectedCode)                    
                                return result;
                            elsif (code==ItunesController::Code::JSON.to_i or code==ItunesController::Code::TEXT.to_i)
                                data = $2[1..$2.length]+"\n"
                                if stream != nil
                                    stream.print(data)
                                end
                                result = result + data
                            end
                        end
                    end
                end
                ItunesController::ItunesControllerLogging::error("Did not receive expected response from server for command #{cmd}")
                @exitHandler.doExit(2)                            
            end        
        end               
        
        def readConfig()        
            @config=ItunesController::ClientConfig.readConfig(@options[:config])
            if (!ItunesController::ClientConfig::validate(@config))
                @exitHandler.doExit(1)
            end
        end
        
        def exec(args)        
            parseOptions(args)
            readConfig()
            connect()        
            login()
            execApp(args)
            quit()
        end
        
        def execApp()
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    end
end

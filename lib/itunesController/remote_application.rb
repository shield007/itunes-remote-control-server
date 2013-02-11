require 'itunesController/logging'
require 'itunesController/version'
require 'itunesController/config'
require 'itunesController/controllserver'

require 'rubygems'
require 'optparse'
require 'net/telnet'

module ItunesController
    class RemoteApplication
        
        def initialize(appName)
            @appName = appName
            @options = {}
            @options[:logFile] = nil
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
            puts("Usage: "+@appName+" [options]")
            puts("")
            puts(genericOptionDescription())
        end        
    
        # Used to display a error message and the command line usesage
        # @param [String] message The error message
        def usageError(message)
            $stderr.puts "ERROR: "+message
            displayUsage()
            exit(1)
        end
    
        # Used to check the command line options are valid
        def checkOptions
            if (@options[:config]==nil)
                usageError("No config file specified. Use --config option.")
            end
            checkAppOptions        
        end
    
        # Parse the command line options
        def parseOptions
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
                    puts "#{@appName} "+ItunesController::VERSION
                    puts "Copyright (C) 2012 John-Paul Stanford"
                    puts "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
                    puts "This is free software: you are free to change and redistribute it."
                    puts "There is NO WARRANTY, to the extent permitted by law."
                    puts ""
                    puts "Authors: John-Paul Stanford <dev@stanwood.org.uk>"
                    puts "Website: http://code.google.com/p/itunes-remote-control-server/"
                end
                opts.on_tail( '-h', '--help', 'Display this screen' ) do
                    puts opts
                    exit
                end
                end
            optparse.parse!
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
        end
        
        # Login to the remote server
        def login()
            sendCommand(ItunesController::CommandName::LOGIN+":"+@config.username,222); 
            sendCommand(ItunesController::CommandName::PASSWORD+":"+@config.password,223); 
        end
        
        # Check the remote server is responding
        def ping()
            sendCommand('#{ItunesController::CommandName::HELO}:#{password}',220)
        end
        
        # Terminate connection to the remote server
        def quit()
            sendCommand(ItunesController::CommandName::QUIT,221)
        end
        
        # Notify the remote server of a file that an action is to be performed on
        # @param file The file
        def file(file)
            sendCommand('#{ItunesController::CommandName::FILE}:#{path}',220)
        end
        
        def addFiles()
            sendCommand('#{ItunesController::CommandName::ADDFILES}',220)       
        end
            
        def sendCommand(cmd, expectedCode)
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
                ItunesController::ItunesControllerLogging::error("Did not receive expected response from server")
                exit(2)            
            end        
        end
        
        def readConfig()        
            @config=ItunesController::ClientConfig.readConfig(@options[:config])
            if (!ItunesController::ClientConfig::validate(@config))
                exit(1)
            end
        end
        
        def exec()        
            parseOptions()
            readConfig()
            connect()        
            login()
            execApp()
            quit()
        end
        
        def execApp()
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    end
end
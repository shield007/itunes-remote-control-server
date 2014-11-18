#
# Copyright (C) 2011-2012  John-Paul.Stanford <dev@stanwood.org.uk>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#


require 'gserver'
require 'json'

require 'itunesController/version'
require 'itunesController/debug'
require 'itunesController/logging'
require 'itunesController/commands'
require 'itunesController/codes'

module ItunesController    
    
    # Used to store the state within the server of each connected client
    # @attr [Number] state The server state. Either ServerState::NOT_AUTHED, ServerState::DOING_AUTHED or ServerState::AUTHED
    # @attr [Array[String]] files An array that contains the list of registered files the client is working on
    # @attr [String] user The logged in user
    # @attr [ItunesController::ServerConfig] config The server configuration
    class ServerState
        
        attr_accessor :state,:files,:user,:config
        
        NOT_AUTHED=1
        DOING_AUTH=2
        AUTHED=3
        
        def initialize(config)
            @state=ServerState::NOT_AUTHED
            @files=[]
            @config=config           
        end
        
        def clean
            @state=ServerState::NOT_AUTHED
            @files=[]
        end
    end
           
    class Job
        attr_reader :command,:state
        
        def initialize(command,state)
            @state = state
            @command = command
        end
        
        def execute()
            @command.executeSingleThreaded(@state)
        end
        
        def to_s
            return @command.name
        end
    end
    
    class CreateControllerCommand < ServerCommand
        # The constructor        
        # @param [ItunesController::BaseITunesController] controllerCreator The itunes controller class
        def initialize(controllerCreator,config)
            super("CreateController",nil,false,nil,nil)
            @controllerCreator=controllerCreator
            @config = config
        end
                       
        def processData(line,io)            
            return true, "#{ItunesController::Code::OK} ok\r\n"
        end  
        
        def executeSingleThreaded(state)
            begin
                @controller=@controllerCreator.createController(@config.dbConnectionString)
                ItunesController::ItunesControllerLogging::info("Started iTunes control server on port #{@config.port}")
            rescue => e
                ItunesController::ItunesControllerLogging::error(e.message,e)
                exit(2)
            end   
        end
        
        def getController()
            return @controller
        end
    end
    
    # The TCP Socket server used to listen on connections and process commands whcih control itunes.
    # see ItunesController::CommandName for a list of supported commands     
    class ITunesControlServer < GServer             
                      
        # The constructor
        # @param [ItunesController::ServerConfig] config The server configuration
        # @param [Number] port The port to listen on
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class         
        def initialize(config,port,itunes)
            super(port,config.interfaceAddress)
            ItunesController::ItunesControllerLogging::info("Starting iTunes control server....")    
            @exit=false   
            @jobQueue=Queue.new
            @jobQueueThread=Thread.new {
                loop do                    
                    processJobs()
                    if (@exit)
                        break;
                    end
                    sleep(1)
                end                
            }             
            cmd=CreateControllerCommand.new(itunes,config)
            @jobQueue << Job.new(cmd,nil)
            while (cmd.getController()==nil)  
                sleep(1)             
            end
            
            @itunes=cmd.getController()                 
            @state=ServerState.new(config)
            @commands=[
                HelloCommand.new(@state,@itunes),
                QuitCommand.new(@state,@itunes),
                LoginCommand.new(@state,@itunes),
                PasswordCommand.new(@state,@itunes),
                ClearFilesCommand.new(@state,@itunes),
                AddFilesCommand.new(@state,@itunes),
                RemoveFilesCommand.new(@state,@itunes),
                RemoveDeadFilesCommand.new(@state,@itunes),
                FileCommand.new(@state,@itunes),
                RefreshFilesCommand.new(@state,@itunes),
                VersionCommand.new(@state,@itunes),
                ListTracksCommand.new(@state,@itunes),
                ListDeadTracksCommand.new(@state,@itunes),
                TrackInfoCommand.new(@state,@itunes),
                CheckCacheCommand.new(@state,@itunes),
                ServerInfoCommand.new(@state,@itunes),
                ListDeadTracksCommand.new(@state,@itunes),
            ]
           
            Thread.abort_on_exception = true
           
                       
            start()                                                 
        end
        
        def waitForEmptyJobQueue
            while (@jobQueue.size()>0)
                sleep(1)
            end
        end
        
        def killServer()
            @exit=true
            @jobQueueThread.join
            join()
        end
        
        def processJobs()            
            job=@jobQueue.pop
            ItunesController::ItunesControllerLogging::debug("Popped command and executing #{job}")
            begin
                job.execute()
            rescue => e
                ItunesController::ItunesControllerLogging::error("Job #{job} failed",e)                
            end
        end
           
        # This method is called when a client is connected and finished when the client disconnects.
        # @param io A IO Stream that is used to talk to the connected client     
        def serve(io)            
            ItunesController::ItunesControllerLogging::info("Connected")                       
            @state.clean
            io.print "#{ItunesController::Code::Greet} hello\r\n"
            loop do
                if IO.select([io], nil, nil, 2)
                    data = io.readpartial(4096)                    
                    ok,op = processCommands(io,data)
                    if (ok!=nil)                                               
                        io.print op
                        break unless ok                    
                    else
                        io.print "#{ItunesController::Code::ErrorGeneral} ERROR\r\n"
                    end                                           
                end
                if (@exit)
                    break;
                end
            end
            io.print "Send:#{ItunesController::Code::Disconnect} bye\r\n"
            io.close
            @state.clean            
            ItunesController::ItunesControllerLogging::info("Disconnected")
        end
    
        # This is used to workout which command is been executed by the client and execute it.
        # @param io A IO Stream that is used to talk to the connected client
        # @param data The data recived from the client        
        # @return [Boolean,String] The returned status of the command if the command could be found. 
        #                          The first part is false, then the server will disconnect the client. 
        #                          The second part is a string message send to the client. If the 
        #                          command could not be found, then nil,nil is returned.  
        def processCommands(io,data)
            @commands.each do | cmd |
                if (cmd.requiredLoginState==nil || cmd.requiredLoginState==@state.state)
                    begin
                        previousState=@state.clone
                        ok, op = cmd.processLine(data,io)
                        if (ok!=nil)    
                            if (cmd.singleThreaded) 
                                @jobQueue << Job.new(cmd,previousState)
                            end
                            ItunesController::ItunesControllerLogging::debug("Command processed: #{cmd.name}")
                            return ok,op
                        end
                    rescue => exc                
                        ItunesController::ItunesControllerLogging::error("Unable to execute command",exc)                        
                        raise exc.exception(exc.message)
                    end
                end
            end
            return nil,nil
        end                
    end
end

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
require 'itunesController/version'

module ItunesController

    # Used to store the command names used in the server
    class CommandName
        # The HELO command is used to check that the server is respoinding
        HELO="HELO"
        # The QUIT command caused the client to disconnect
        QUIT="QUIT"
        # The login command taks the format LOGIN:<username> and causes the server
        # to prompt for a password. This command is used to start the user login process
        LOGIN="LOGIN"
        # The password command takes the format PASSWORD:<password> and is used to 
        # log the user in if the username and password are correct.
        PASSWORD="PASSWORD"
        # The file command is used to tell the server about files that should be worked on.
        # These files are the path as they are found on the server. This command takes the 
        # format FILE:<filename>
        FILE="FILE"
        # This command is used to remove and registerd files that were registerd with the FILE 
        # command.
        CLEARFILES="CLEARFILES"
        # This command is used to add files registered with the FILE command to itunes then clear
        # the file list.
        ADDFILES="ADDFILES"
        # This command is used to remove files registered with the FILE command from the itunes 
        # library then clear the file list.        
        REMOVEFILES="REMOVEFILES"
        # This command will remove any files in the itunes library where the path points at a file
        # that does not exist.
        REMOVEDEADFILES="REMOVEDEADFILES"
        # This command lists the files in the itunes library which have paths pointing at files 
        # that can't be found
        LISTDEADFILES="LISTDEADFILES"
        # This command is used to get version information
        VERSION="VERSION"
    end
    
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
    
    # This is the base class of all server commands.
    # @abstract Subclass and override {#processData} to implement a server command 
    # @attr_reader [Number] requiredLoginState The required login state need for this command. Either nil,
    #                                          ServerState::NOT_AUTHED, ServerState::DOING_AUTH or
    #                                          ServerState::AUTHED. If nil then works in any login state.
    # @attr_reader [String] name The command name
    class ServerCommand
        attr_reader :requiredLoginState,:name
        
        # The constructor
        # @param [String] name The command name
        # @param [Number] requiredLoginState The required login state need for this command. Either nil,
        #                                    ServerState::NOT_AUTHED, ServerState::DOING_AUTH or
        #                                    ServerState::AUTHED. If nil then works in any login state.
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class    
        def initialize(name,requiredLoginState,state,itunes)
            @name=name
            @state=state
            @itunes=itunes
            @requiredLoginState=requiredLoginState
        end
    
        # This is a virtual method that must be overridden by command classes. This method
        # is used to perform the commands task and return the result to the server.
        # @param [String] data The commands parameters if their are any
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(data,io)
            raise "ERROR: Your trying to instantiate an abstract class"
        end
    
        # @param [String] line A line of text recived from the client containg the command and it's parameters
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If nil, nil is returned by the command,
        #                          then the given line does not match this command. If the first part is false,
        #                          then the server will disconnect the client. The second part is a string message
        #                          send to the client.  
        def processLine(line,io)
            line = line.chop
            if (line.start_with?(@name))
                return processData(line[@name.length,line.length],io)
            end
            return nil,nil
        end
    end
    
    # The HELO command is used to check that the server is respoinding
    class HelloCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::HELO,nil,state,itunes)
        end
    
        # Sends a response to the client "220 ok"
        # @param [String] data The commands parameters if their are any
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(line,io)
            return true, "220 ok\r\n"
        end
    end
    
    # The QUIT command caused the client to disconnect
    class QuitCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::QUIT,nil,state,itunes)
        end

        # Sends the response to the client "221 bye" and causes the client to disconnect
        # @param [String] data The commands parameters if their are any
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client     
        def processData(line,io)
            return false, "221 bye\r\n"
        end
    end
    
    # The login command taks the format LOGIN:<username> and causes the server
    # to prompt for a password. This command is used to start the user login process
    class LoginCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::LOGIN,nil,state,itunes)
        end
    
        # The line is processed to get the username, then the response "222 Password?" is sent to the
        # the client to request the password.
        # @param [String] data The commands parameters if their are any
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(line,io)
            if (line =~ /^\:(.+)$/)
                @state.user=$1
                @state.state=ServerState::DOING_AUTH
                return true,"222 Password?\r\n"
            end
            return false, "502 ERROR no username\r\n"
        end
    end
    
    # The password command takes the format PASSWORD:<password> and is used to 
    # log the user in if the username and password are correct.
    class PasswordCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::PASSWORD,ServerState::DOING_AUTH,state,itunes)
        end
    
        # The line is processed to get the password. Then the authentication deatials are checked.
        # If they pass, then the user is now logged in and the server state changes to 
        # ItunesController::ServerState::AUTH with a reply to the client of "223 Logged in".
        # If the autentication check fails, then a reply ""501 Incorrect username/password" is sent
        # and the client is disconnected.
        # @param [String] data The commands parameters if their are any
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(line,io)
            if (line =~ /^\:(.+)$/)
                if (checkAuth(@state.user,$1))
                    @state.state = ServerState::AUTHED
                    return true,"223 Logged in\r\n"
                end
            end
            return false,"501 Incorrect username/password\r\n"
        end
    
    private
    
        # Used to check the username and password agaist the details found in the server configuartion
        # @param [String] user The username
        # @param [String] password The password of the user
        # @return [Boolean] True if the authenction check passes, otherwise false
        def checkAuth(user,password)        
            return (user==@state.config.username && password==@state.config.password)
        end    
    end
    
    # This command is used to remove and registerd files that were registerd with the FILE 
    # command.
    class ClearFilesCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::CLEARFILES,ServerState::AUTHED,state,itunes)
        end
    
        def processData(line,io)
            @state.files=[]
            return true, "220 ok\r\n"
        end
    end
    
    # This command is used to add files registered with the FILE command to itunes then clear
    # the file list.
    class AddFilesCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::ADDFILES,ServerState::AUTHED,state,itunes)
        end
    
        def processData(line,io)
            @itunes.addFilesToLibrary(@state.files)
            @state.files=[]
            return true, "220 ok\r\n"
        end
    end
    
    # This command is used to remove files registered with the FILE command from the itunes 
    # library then clear the file list.
    class RemoveFilesCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::REMOVEFILES,ServerState::AUTHED,state,itunes)
        end
    
        def processData(line,io)
            files=@itunes.findTracksWithLocations(@state.files)
            @itunes.removeTracksFromLibrary(files)
            return true, "220 removed #{files.count} from library\r\n"
        end
    end
    
    # This command will remove any files in the itunes library where the path points at a file
    # that does not exist.
    class RemoveDeadFilesCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::REMOVEDEADFILES,ServerState::AUTHED,state,itunes)
        end
    
        def processData(line,io)
            deadTracks=@itunes.findDeadTracks()
            @itunes.removeTracksFromLibrary(deadTracks)
            return true, "220 removed #{deadTracks.count} from library\r\n"
        end
    end
    
    # This command lists the files in the itunes library which have paths pointing at files 
    # that can't be found
    class ListDeadFilesCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::LISTDEADFILES,ServerState::AUTHED,state,itunes)
        end
    
        def processData(line,io)
            deadTracks=@itunes.findDeadTracks()
            deadTracks.each do | deadTrack | 
                if (deadTrack.show!=nil && deadTrack.show!="")
                    io.puts "TV: "+deadTrack.show+" - " + deadTrack.name
                else
                    io.puts "Film: "+deadTrack.name
                end
            end
            return true, "220 found #{deadTracks.count} dead tracks\r\n"
        end
    end
    
    # The file command is used to tell the server about files that should be worked on.
    # These files are the path as they are found on the server. This command takes the 
    # format FILE:<filename>
    class FileCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::FILE,ServerState::AUTHED,state,itunes)
        end
    
        def processData(line,io)
            if (line =~ /^\:(.+)$/)
                @state.files.push($1)
                return true, "220 ok\r\n"
            end
            return true, "503 ERROR expected file\r\n"
        end
    end
    
    # This command is used to return version information
    class VersionCommand < ServerCommand
        
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::ItunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::VERSION,nil,state,itunes)
        end
                       
        def processData(line,io)
            io.puts("ITunes control server:" +ItunesController::VERSION)
            io.puts("Apple iTunes version: "+@itunes.version)
            return true, "220 ok\r\n"
        end
    end
    
    # The TCP Socket server used to listen on connections and process commands whcih control itunes.
    # see ItunesController::CommandName for a list of supported commands     
    class ITunesControlServer < GServer             
              
        # The constructor
        # @param [ItunesController::ServerConfig] config The server configuration
        # @param [Number] port The port to listen on
        # @param [ItunesController::ItunesController] itunes The itunes controller class         
        def initialize(config,port,itunes)
            super(port,config.interfaceAddress)
            puts "Started iTunes controll server on port #{port}"                   
            @itunes=itunes                 
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
                ListDeadFilesCommand.new(@state,@itunes),
                FileCommand.new(@state,@itunes),
                VersionCommand.new(@state,@itunes)
            ]
                 
        end
           
        # This method is called when a client is connected and finished when the client disconnects.
        # @param io A IO Stream that is used to talk to the connected client     
        def serve(io)
            puts "Connected"
            @state.clean
            io.print "001 hello\r\n"
            loop do
                if IO.select([io], nil, nil, 2)
                    data = io.readpartial(4096)
                    ok,op = processCommands(io,data)
                    if (ok!=nil)
                        io.print op
                        break unless ok                    
                    else
                        io.print "500 ERROR\r\n"
                    end
    
                end
            end
            io.print "Send:002 bye\r\n"
            io.close
            @state.clean            
            puts "Disconnected"
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
                    ok, op = cmd.processLine(data,io)
                    if (ok!=nil)
                        return ok,op
                    end
                end
            end
            return nil,nil
        end
    end
end

require 'itunesController/codes'
require 'rubygems'
require 'stringio'
require 'json'

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
        # This command is used to tell iTunes to refresh the metadata from the file of files registered
        # with the FILE command from the itunes library then clear the file list.
        REFRESHFILES="REFRESHFILES"
        # This command is used to get version information
        VERSION="VERSION"
        # This command is used to list tracks
        LISTTRACKS="LISTTRACKS"
        # This command is used to list dead tracks
        LISTDEADTRACKS="LISTDEADTRACKS"
        # This command is used to get information about a track
        TRACKINFO="TRACKINFO"
        # This command is used to check the cache is uptodate and if not regenerate it
        CHECKCACHE="CHECKCACHE"
        # This command is used to get info about the server
        SERVERINFO="SERVERINFO"
    end

    # This is the base class of all server commands.
    # @abstract Subclass and override {#processData} to implement a server command
    # @attr_reader [Number] requiredLoginState The required login state need for this command. Either nil,
    #                                          ServerState::NOT_AUTHED, ServerState::DOING_AUTH or
    #                                          ServerState::AUTHED. If nil then works in any login state.
    # @attr_reader [String] name The command name
    class ServerCommand
        attr_reader :requiredLoginState,:name,:singleThreaded
        # The constructor
        # @param [String] name The command name
        # @param [Number] requiredLoginState The required login state need for this command. Either nil,
        #                                    ServerState::NOT_AUTHED, ServerState::DOING_AUTH or
        #                                    ServerState::AUTHED. If nil then works in any login state.
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(name,requiredLoginState,singleThreaded,state,itunes)
            @name=name
            @state=state
            @itunes=itunes
            @requiredLoginState=requiredLoginState
            @singleThreaded=singleThreaded
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

        # This is executed when the command is popped from the job queue. It is used to force single
        # threaded access to itunes
        # @param [ServerState] state The state of the server
        def executeSingleThreaded(state)
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
                ItunesController::ItunesControllerLogging::debug("Command recived: #{@name}")
                return processData(line[@name.length,line.length],io)
            end
            return nil,nil
        end
    end

    # The HELO command is used to check that the server is respoinding
    class HelloCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::HELO,nil,false,state,itunes)
        end

        # Sends a response to the client "220 ok"
        # @param [String] line The line of data
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(line,io)
            return true, "#{ItunesController::Code::OK} ok\r\n"
        end
    end

    # The QUIT command caused the client to disconnect
    class QuitCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::QUIT,nil,false,state,itunes)
        end

        # Sends the response to the client "221 bye" and causes the client to disconnect
        # @param [String] line The line of data
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(line,io)
            return false, "#{ItunesController::Code::Bye} bye\r\n"
        end
    end

    # The login command taks the format LOGIN:<username> and causes the server
    # to prompt for a password. This command is used to start the user login process
    class LoginCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::LOGIN,nil,false,state,itunes)
        end

        # The line is processed to get the username, then the response "222 Password?" is sent to the
        # the client to request the password.
        # @param [String] line The line of data
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(line,io)
            if (line =~ /^\:(.+)$/)
                @state.user=$1
                @state.state=ServerState::DOING_AUTH
                return true,"#{ItunesController::Code::PasswordPrompt} Password?\r\n"
            end
            return false, "#{ItunesController::Code::ErrorNoUsername} ERROR no username\r\n"
        end
    end

    # The password command takes the format PASSWORD:<password> and is used to
    # log the user in if the username and password are correct.
    class PasswordCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::PASSWORD,ServerState::DOING_AUTH,false,state,itunes)
        end

        # The line is processed to get the password. Then the authentication deatials are checked.
        # If they pass, then the user is now logged in and the server state changes to
        # ItunesController::ServerState::AUTH with a reply to the client of "223 Logged in".
        # If the autentication check fails, then a reply ""501 Incorrect username/password" is sent
        # and the client is disconnected.
        # @param [String] line The line of data
        # @param io A IO Stream that is used to talk to the connected client
        # @return [Boolean,String] The returned status of the command. If the first part is false, then
        #                          the server will disconnect the client. The second part is a string message
        #                          send to the client
        def processData(line,io)
            if (line =~ /^\:(.+)$/)
                if (checkAuth(@state.user,$1))
                    @state.state = ServerState::AUTHED
                    return true,"#{ItunesController::Code::Authenticated} Logged in\r\n"
                end
            end
            return false,"#{ItunesController::Code::ErrorWrongCredentials} Incorrect username/password\r\n"
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
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::CLEARFILES,ServerState::AUTHED,false,state,itunes)
        end
        def processData(line,io)

            @state.files=[]
            return true, "#{ItunesController::Code::OK} ok\r\n"
        end
    end

    # This command is used to add files registered with the FILE command to itunes then clear
    # the file list. This will return a code 220 if it successeds, or 504 if their is a error.
    class AddFilesCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::ADDFILES,ServerState::AUTHED,true,state,itunes)
        end

        def processData(line,io)
            @state.files=[]
            return true, "#{ItunesController::Code::OK} ok\r\n"
        end

        # This is executed when the command is popped from the job queue. It is used to force single
        # threaded access to itunes
        # @param [ServerState] state The state of the server
        def executeSingleThreaded(state)
            @itunes.cacheTracks()
            state.files.each do | path |
                @itunes.addTrack(path)
            end
        end
    end

    class CheckCacheCommand < ServerCommand
        def initialize(state,itunes)
            super(ItunesController::CommandName::CHECKCACHE,ServerState::AUTHED,false,state,itunes)
        end

        def processData(line,io)
            force=false
            if (line =~ /^\:(.+)$/)
                if $1.downcase()=="true"
                    force=true
                end
            end
            
            result=""
            if (@itunes.needsRecacheTracks() || force)
                result=result+"101:Cache is dirty, Running update\r\n"
                @state.doCacheUpdate = true                
            else 
                result=result+"101:Cache is uptodate\r\n"
                @state.doCacheUpdate = false
            end            
            result=result+"#{ItunesController::Code::OK} ok\r\n"
                        
            return true, result
        end
        
        def executeSingleThreaded(state)
            if (state.doCacheUpdate)
                @itunes.cacheTracks(force)
                state.doCacheUpdate = false                
            end            
        end
    end

    class ListTracksCommand < ServerCommand
        def initialize(state,itunes)
            super(ItunesController::CommandName::LISTTRACKS,ServerState::AUTHED,false,state,itunes)
        end

        def processData(line,io)
            result=""
            tracks = []
            @itunes.getCachedTracks().each do | track |
                tracks.push({ 'location' => track.location,
                    'databaseId' => track.databaseId,
                    'title' => track.title})
            end
            tempHash = { "tracks" =>    tracks }
            JSON.pretty_generate(tempHash).each_line do | line |
                result = result+"#{ItunesController::Code::JSON}:"+line.chomp+"\r\n"
            end
            result = result+"#{ItunesController::Code::OK} ok\r\n"
            return true, result
        end

    end
    
    class ListDeadTracksCommand < ServerCommand
        def initialize(state,itunes)
            super(ItunesController::CommandName::LISTDEADTRACKS,ServerState::AUTHED,false,state,itunes)
        end

        def processData(line,io)
            result=""
            tracks = []
            @itunes.findDeadTracks().each do | track |
                tracks.push({ 'databaseId' => track.databaseId,
                              'title' => track.title})
            end
            tempHash = { "tracks" =>    tracks }
            JSON.pretty_generate(tempHash).each_line do | line |
                result = result+"#{ItunesController::Code::JSON}:"+line.chomp+"\r\n"
            end
            result = result+"#{ItunesController::Code::OK} ok\r\n"
            return true, result
        end
    end

    class TrackInfoCommand < ServerCommand
        def initialize(state,itunes)
            super(ItunesController::CommandName::TRACKINFO,ServerState::AUTHED,false,state,itunes)
        end

        def processData(line,io)
            track = nil
            #            if (line =~ /^\:id\:(\d+)$/)
            #                track = @itunes.getTrackByDatabaseId($1.to_i)
            if (line =~ /^\:path\:(.+)$/)
                ItunesController::ItunesControllerLogging::debug("Getting info for track: "+$1)
                track = @itunes.getTrack(File.expand_path($1))
            else
                return true,"#{ItunesController::Code::ErrorGeneral} Unable to parse path\r\n"
            end
            result=""
            if track!=nil
                ItunesController::ItunesControllerLogging::debug("Got track #{track}")
                # TODO add other fields of the track that were fetched from iTunes
                JSON.pretty_generate({ 'location' => track.location,
                    'databaseId' => track.databaseID,
                    'title' => track.name}).each_line do | line |
                    result = result+"#{ItunesController::Code::JSON}:"+line.chomp+"\r\n"
                end
                result = result+"#{ItunesController::Code::OK} ok\r\n"
            else
                ItunesController::ItunesControllerLogging::debug("Unable to find track")
                result="#{ItunesController::Code::JSON}:{}\r\n"
                result = result+"#{ItunesController::Code::NotFound} Not Found\r\n"
            end
            
            return true, result
        end
    end

    # This command is used to refresh files registerd with the FILE command. It tells iTunes
    # to update the meta data from the information stored in the files.
    class RefreshFilesCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::REFRESHFILES,ServerState::AUTHED,true,state,itunes)
        end

        def processData(line,io)
            @state.files=[]
            return true, "#{ItunesController::Code::OK} ok\r\n"
        end

        # This is executed when the command is popped from the job queue. It is used to force single
        # threaded access to itunes
        # @param [ServerState] state The state of the server
        def executeSingleThreaded(state)
            @itunes.cacheTracks()
            state.files.each do | path |
                @itunes.updateTrack(path)
            end
        end
    end

    # This command is used to remove files registered with the FILE command from the itunes
    # library then clear the file list.
    class RemoveFilesCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::REMOVEFILES,ServerState::AUTHED,true,state,itunes)
        end

        def processData(line,io)
            @state.files=[]
            return true, "#{ItunesController::Code::OK} ok\r\n"
        end

        # This is executed when the command is popped from the job queue. It is used to force single
        # threaded access to itunes
        # @param [ServerState] state The state of the server
        def executeSingleThreaded(state)
            @itunes.cacheTracks()
            state.files.each do | path |
                @itunes.removeTrack(path)
            end
        end
    end

    # This command will remove any files in the itunes library where the path points at a file
    # that does not exist.
    class RemoveDeadFilesCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::REMOVEDEADFILES,ServerState::AUTHED,true,state,itunes)
        end

        def processData(line,io)

            return true, "#{ItunesController::Code::OK} ok\r\n"
        end

        # This is executed when the command is popped from the job queue. It is used to force single
        # threaded access to itunes
        # @param [ServerState] state The state of the server
        def executeSingleThreaded(state)
            @itunes.cacheTracks()
            @itunes.removeDeadTracks()
        end
    end

    # The file command is used to tell the server about files that should be worked on.
    # These files are the path as they are found on the server. This command takes the
    # format FILE:<filename>
    class FileCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::FILE,ServerState::AUTHED,false,state,itunes)
        end

        def processData(line,io)
            if (line =~ /^\:(.+)$/)
                @state.files.push(File.expand_path($1))
                return true, "#{ItunesController::Code::OK} ok\r\n"
            end
            return true, "#{ItunesController::Code::ErrorMissingParam} ERROR expected file\r\n"
        end
    end

    # This command is used to return version information
    class VersionCommand < ServerCommand
        # The constructor
        # @param [ItunesController::ServerState] state The status of the connected client within the server
        # @param [ItunesController::BaseITunesController] itunes The itunes controller class
        def initialize(state,itunes)
            super(ItunesController::CommandName::VERSION,nil,false,state,itunes)
        end

        def processData(line,io)
            result=""
            tempHash = { "server" => ItunesController::VERSION,
                         "iTunes" =>  @itunes.getItunesVersion }
            JSON.pretty_generate(tempHash).each_line do | line |
                result = result+"#{ItunesController::Code::JSON}:"+line.chomp+"\r\n"
            end
            result = result+"#{ItunesController::Code::OK} ok\r\n"
            return true, result
        end
    end
    
    class ServerInfoCommand < ServerCommand
        
        def initialize(state,itunes)
            super(ItunesController::CommandName::SERVERINFO,nil,false,state,itunes)
        end

        def processData(line,io)
            result=""
            tempHash = { 
                         "cacheDirty" => @itunes.needsRecacheTracks(),
                         "cachedTrackCount" => @itunes.getDatabase().getTrackCount(),                
                         "cachedDeadTrackCount" => @itunes.getDatabase().getDeadTrackCount(),
                         "cachedLibraryTrackCount" => @itunes.getDatabase().getParam(ItunesController::Database::PARAM_KEY_TRACK_COUNT,0).to_i,
                         "libraryTrackCount" => @itunes.getLibraryTrackCount()
                        }
            JSON.pretty_generate(tempHash).each_line do | line |
                result = result+"#{ItunesController::Code::JSON}:"+line.chomp+"\r\n"
            end
            result = result+"#{ItunesController::Code::OK} ok\r\n"
            return true, result
        end
    end

end

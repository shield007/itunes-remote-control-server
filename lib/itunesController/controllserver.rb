
require 'gserver'

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

class ServerCommand
    attr_reader :requiredLoginState,:name
    def initialize(name,requiredLoginState,state,itunes)
        @name=name
        @state=state
        @itunes=itunes
        @requiredLoginState=requiredLoginState
    end

    def processData(data,io)
        raise "ERROR: Your trying to instantiate an abstract class"
    end

    def processLine(line,io)
        line = line.chop
        if (line.start_with?(@name))
            return processData(line[@name.length,line.length],io)
        end
        return nil,nil
    end
end

# This command is used check that the server is responding
class HelloCommand < ServerCommand
    def initialize(state,itunes)
        super("HELO",nil,state,itunes)
    end

    def processData(line,io)
        return true, "220 ok\r\n"
    end
end

# This command is used to close the connection to the server
class QuitCommand < ServerCommand
    def initialize(state,itunes)
        super("QUIT",nil,state,itunes)
    end

    def processData(line,io)
        return false, "221 bye\r\n"
    end
end

# This command is used to log into the server and tell it the username
class LoginCommand < ServerCommand
    def initialize(state,itunes)
        super("LOGIN",nil,state,itunes)
    end

    def processData(line,io)
        if (line =~ /^\:(.+)$/)
            @state.user=$1
            @state.state=ServerState::DOING_AUTH
            return true,"222 Password?\r\n"
        end
        return false, "502 ERROR no username\r\n"
    end
end

# This command is used to log into the server and tell it the password
class PasswordCommand < ServerCommand
    def initialize(state,itunes)
        super("PASSWORD",ServerState::DOING_AUTH,state,itunes)
    end

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

    def checkAuth(user,password)        
        return (user==@state.config.username && password==@state.config.password)
    end    
end

# This command is used to clear the registers files
class ClearFilesCommand < ServerCommand
    def initialize(state,itunes)
        super("CLEARFILES",ServerState::AUTHED,state,itunes)
    end

    def processData(line,io)
        @state.files=[]
        return true, "220 ok\r\n"
    end
end

# This command will cause files registerd with the server to be added to the itunes library
class AddFilesCommand < ServerCommand
    def initialize(state,itunes)
        super("ADDFILES",ServerState::AUTHED,state,itunes)
    end

    def processData(line,io)
        @itunes.addFilesToLibrary(@state.files)
        @state.files=[]
        return true, "220 ok\r\n"
    end
end

# This command will cause files registerd with the server to be removed from the itunes library
class RemoveFilesCommand < ServerCommand
    def initialize(state,itunes)
        super("REMOVEFILES",ServerState::AUTHED,state,itunes)
    end

    def processData(line,io)
        files=@itunes.findTracksWithLocations(@state.files)
        @itunes.removeTracksFromLibrary(files)
        return true, "220 removed #{files.count} from library\r\n"
    end
end

# This command will remove files form the itunes library if they can't be found on the disk
class RemoveDeadFilesCommand < ServerCommand
    def initialize(state,itunes)
        super("REMOVEDEADFILES",ServerState::AUTHED,state,itunes)
    end

    def processData(line,io)
        deadTracks=@itunes.findDeadTracks()
        @itunes.removeTracksFromLibrary(deadTracks)
        return true, "220 removed #{deadTracks.count} from library\r\n"
    end
end

# This is used to get a list of files in the itunes library which can't be found on the disk
class ListDeadFilesCommand < ServerCommand
    def initialize(state,itunes)
        super("LISTDEADFILES",ServerState::AUTHED,state,itunes)
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

# This command is used to register a file with the server. These files can then be used by other commands
class FileCommand < ServerCommand
    def initialize(state,itunes)
        super("FILE",ServerState::AUTHED,state,itunes)
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
    def initialize(state,itunes)
        super("VERSION",nil,state,itunes)
    end
    
    def processData(line,io)
        io.puts("ITunes control server:" +ITunesControlServer::SERVER_VERSION)
        io.puts("Itunes version: "+@itunes.version)
        return true, "220 ok\r\n"
    end
end

class ITunesControlServer < GServer
    
    SERVER_VERSION="1.0"
    
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
        io.print "002 bye\r\n"
        io.close
        @state.clean
        puts "Disconnected"
    end

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

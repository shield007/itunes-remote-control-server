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

require 'rexml/document'
include REXML

module ItunesController    

    # This class is used to save read and store the server configuration
    # @example {
    #    <itunesController>
    #        <users>
    #            <user username="test" password="test"/>
    #        </users>
    #        <database connection="sqlite:/">
    #    </itunesController>
    # }
    # @attr username The username of the user used to connect to login to the server
    # @attr password The password of the user used to connect to login to the server
    # @attr port The port number the server is listening on
    # @attr interfaceAddress The DNS/IP address of the interface the server is binding too. 
    class ServerConfig
        attr_accessor :username,:password,:port,:interfaceAddress,:dbConnectionString
        
        # The constructor
        def initialize()
            @port =nil
            @interfaceAddress = "localhost"
            @dbConnectionString = nil
        end
    
        # A class scoped method used to read the server configuration from a file
        # See the class description for a example of the configuration file format. 
        # If their are any problems loading the configuration, then the application is
        # exited and a error message is printed to the stderr console stream.
        # @param [String] configFile The file name of the configuration file
        # @return [ItunesController::ServerConfig] The server configuration
        def self.readConfig(configFile)
            ItunesController::ItunesControllerLogging::debug("Reading configuration #{configFile}")
            if (!File.exists? configFile)
                raise("Unable to find configuration file: "+configFile)
            end 
                 
            config=ServerConfig.new
            begin        
                doc=Document.new(File.new( configFile ))
                  
                rootEl = doc.root.elements["/itunesController"]       
                if (rootEl==nil)
                    raise("Unable to find parse configuartion file, can't find node /itunesController")
                end     
                if (rootEl.attributes["port"]!=nil && rootEl.attributes["port"]!="")
                    config.port = rootEl.attributes["port"].to_i
                end
                if (rootEl.attributes["interfaceAddress"]!=nil && rootEl.attributes["interfaceAddress"]!="")
                    config.interfaceAddress = rootEl.attributes["interfaceAddress"]
                end
                
                doc.elements.each("/itunesController/users/user") { |userElement| 
                    config.username=userElement.attributes["username"]
                    config.password=userElement.attributes["password"]
                }
                doc.elements.each("/itunesController/database") { | dbElement |                    
                    config.dbConnectionString = dbElement.attributes['connection']
                    ItunesController::ItunesControllerLogging::debug("Read connection string #{config.dbConnectionString}")
                }
            
            rescue EOFError
                raise("Unable to read or parse the configuration file: " + configFile)
            end
            
            if (config.username==nil)
                raise("Username name missing in configuration file")
            end
            
            if (config.password==nil)
                raise("Password name missing in configuration file")
            end        
            
            return config
        end    
    end
    
    # This class is used to save read and store the client configuration
    # @example {
    #    <itunesController port="7000" hostname="localhost">
    #        <users>
    #            <user username="test" password="test"/>
    #        </users>
    #    </itunesController>
    # }
    # @attr username The username of the user used to connect to login to the server
    # @attr password The password of the user used to connect to login to the server
    # @attr port The port number the server is listening on
    # @attr interfaceAddress The DNS/IP address of the interface the server is binding too. 
    class ClientConfig
        attr_accessor :username,:password,:port,:hostname
                
        # The constructor
        def initialize()
            @port =nil
            @hostname = "localhost"
            @username = nil
            @password = nil
        end
    
        # A class scoped method used to read the server configuration from a file
        # See the class description for a example of the configuration file format. 
        # If their are any problems loading the configuration, then the application is
        # exited and a error message is printed to the stderr console stream.
        # @param [String] configFile The file name of the configuration file
        # @return [ItunesController::ServerConfig] The server configuration
        def self.readConfig(configFile)
            if (!File.exists? configFile)
                raise("Unable to find configuration file: "+configFile)
            end 
                 
            config=ClientConfig.new
            begin        
                doc=Document.new(File.new( configFile ))
                    
                rootEl = doc.root.elements["/itunesController"]       
                if (rootEl==nil)
                    raise("Unable to find parse configuartion file, can't find node /itunesController")
                end     
                if (rootEl.attributes["port"]!=nil && rootEl.attributes["port"]!="")
                    config.port = rootEl.attributes["port"].to_i
                end
                if (rootEl.attributes["hostname"]!=nil && rootEl.attributes["hostname"]!="")
                    config.hostname = rootEl.attributes["hostname"]
                end
                        
                doc.elements.each("/itunesController/users/user") { |userElement| 
                    config.username=userElement.attributes["username"]
                    config.password=userElement.attributes["password"]
                }                       
            
            rescue EOFError
                raise("Unable to read or parse the configuration file: " + configFile)
            end
            
            if (config.username==nil)
                raise("Username name missing in configuration file")
            end
            
            if (config.password==nil)
                raise("Password name missing in configuration file")
            end        
            
            return config
        end
        def self.validate(config)
            if (config.port==nil)
                $stderr.puts "ERROR: No port in configuration file"
                return false
            end
            if (config.username==nil)
                $stderr.puts "ERROR: No username in configuration file"
                return false
            end
            if (config.password==nil)
                $stderr.puts "ERROR: No password in configuration file"
                return false
            end
            return true        
        end
    end
    
    
end

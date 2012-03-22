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

require 'rexml/document'
include REXML

module ItunesController    

    # This class is used to save read and store the server configuration
    # @example {
    #    <itunesController>
    #        <users>
    #            <user username="test" password="test"/>
    #        </users>
    #    </itunesController>
    # }
    # @attr username The username of the user used to connect to login to the server
    # @attr password The password of the user used to connect to login to the server
    # @attr port The port number the server is listening on
    # @attr interfaceAddress The DNS/IP address of the interface the server is binding too. 
    class ServerConfig
        attr_accessor :username,:password,:port,:interfaceAddress
        
        # The constructor
        def initialize()
            @port =nil
            @interfaceAddress = "localhost"
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
end

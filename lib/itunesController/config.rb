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
    
    class ServerConfig
        attr_accessor :username,:password,:port,:interfaceAddress
        
        def initialize()
            @port =nil
            @interfaceAddress = "127.0.0.1"
        end
    
        def self.readConfig(configFile)
            if (!File.exists? configFile)
                error("Unable to find configuration file: "+configFile)
            end 
                 
            config=ServerConfig.new
            begin        
                doc=Document.new(File.new( configFile ))
                    
                rootEl = doc.root.elements["/itunesController"]       
                if (rootEl==nil)
                    error("Unable to find parse configuartion file, can't find node /itunesController")
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
                error("Unable to read or parse the configuration file: " + configFile)
            end
            
            if (config.username==nil)
                error("Username name missing in configuration file")
            end
            
            if (config.password==nil)
                error("Password name missing in configuration file")
            end        
            
            return config
        end
    
    end
end

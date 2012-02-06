require 'rexml/document'

include REXML

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

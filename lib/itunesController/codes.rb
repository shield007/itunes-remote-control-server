module ItunesController
    class Code
        Greet = "001"
        Disconnect = "002"
        JSON = "100"
        TEXT = "101"
        OK = "220"
        Bye = "221"        
        PasswordPrompt = "222"
        Authenticated = "223"
        NotFound = "404"
        ErrorGeneral = "500"
        ErrorWrongCredentials = "501"
        ErrorNoUsername = "502"
        ErrorMissingParam = "503"
        Unknown = "999"                      
        
        # Get the code object from the number value
        # @param value The number value
        def self.fromNumber(value)
            @@values.each { | v1 |
                if (v1.to_i == value)
                    return v1
                end
            }
            return Code::Unknown
        end
        
    end
end
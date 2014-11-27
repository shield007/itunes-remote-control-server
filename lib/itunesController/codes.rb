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
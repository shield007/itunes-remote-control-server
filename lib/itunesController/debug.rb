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
    
    class ItunesControllerDebug     
                     
        ANSI_BOLD = "\033[1m"
        ANSI_RESET = "\033[0m"
        ANSI_LGRAY = "\033[0;37m"
        ANSI_GRAY = "\033[1;30m"                  
        
        # Used to print the methods of a object
        # @param [Object] obj The object
        # @param options
        def self.pm(obj, *options)
            methods = obj.methods
            methods -= Object.methods unless options.include? :more
            filter = options.select {|opt| opt.kind_of? Regexp}.first
            methods = methods.select {|name| name =~ filter} if filter

            data = methods.sort.collect do |name|
                method = obj.method(name)
                if method.arity == 0
                    args = "()"
                elsif method.arity > 0
                    n = method.arity
                    args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
                elsif method.arity < 0
                    n = -method.arity
                    args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
                end
                klass = $1 if method.inspect =~ /Method: (.*?)#/
                [name, args, klass]
            end
            max_name = data.collect {|item| item[0].size}.max
            max_args = data.collect {|item| item[1].size}.max
            data.each do |item|
                print " #{ANSI_BOLD}#{item[0].to_s.rjust(max_name)}#{ANSI_RESET}"
                print "#{ANSI_GRAY}#{item[1].ljust(max_args)}#{ANSI_RESET}"
                print "   #{ANSI_LGRAY}#{item[2]}#{ANSI_RESET}\n"
            end
            data.size
        end
        
        # Used to print the methods of a ole object
        # @param [Object] obj The object   
        # @param options   
        def self.pm_ole(obj, *options)
            methods = obj.ole_methods 
            methods -= Object.methods unless options.include? :more
            filter = options.select {|opt| opt.kind_of? Regexp}.first
            methods = methods.select {|name| name =~ filter} if filter     
                      
            data = methods.collect do |m|
                name = m.to_s               
                method = obj.ole_method(name)                 
                [name, "("+method.params.join(",")+")", method.return_type_detail,method.helpstring]
            end
            max_name = data.collect {|item| item[0].size}.max
            max_args = data.collect {|item| item[1].size}.max
            data.each do |item|
                print " #{ANSI_BOLD}#{item[0].to_s.rjust(max_name)}#{ANSI_RESET}"
                print "#{ANSI_GRAY}#{item[1].ljust(max_args)}#{ANSI_RESET}"
                print "   #{ANSI_LGRAY}#{item[2]}#{ANSI_RESET}\n"
            end
            data.size
        end
        
        # Used to print the methods of a objc object
        # @param [Object] obj The object   
        # @param options   
        def self.pm_objc(obj, *options)
            methods = obj.objc_methods 
            puts methods
        end

        # Used to print track information
        # @param track iTunes track
        def self.printTrack(track)
            puts getTrackDescription(track)
        end      

        # Used to get a track description
        # @param track iTunes track
        # @return the track information
        def self.getTrackDescription(track)
            result=[]
            if (track.show!=nil && track.show!="")
                result.push("Type: TV Episode")
                result.push("Show Name: "+track.show)
            else
                result.push("Type: Film")
            end
            result.push("Name: "+track.name)
            if (Platform.isWindows())
                result.push("Database ID: "+track.TrackDatabaseID.to_s)
                result.push("Location: "+track.location)
            else
                result.push("Database ID: "+track.databaseID.to_s)
                result.push("Location: "+track.location.path)
            end            
            return result.join("\n")
        end
    end
end

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

module ItunesController

    ANSI_BOLD       = "\033[1m"
    ANSI_RESET      = "\033[0m"
    ANSI_LGRAY    = "\033[0;37m"
    ANSI_GRAY     = "\033[1;30m"
    
    def pm(obj, *options) # Print methods
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
            print " #{ANSI_BOLD}#{item[0].rjust(max_name)}#{ANSI_RESET}"
            print "#{ANSI_GRAY}#{item[1].ljust(max_args)}#{ANSI_RESET}"
            print "   #{ANSI_LGRAY}#{item[2]}#{ANSI_RESET}\n"
          end
          data.size
    end
    
    def printTack(track)
        puts getTrackDescription(track)
    end
    
    def getTrackDescription(track)
        if (track.show!=nil && track.show!="")
            return track.show+" - " + track.name
        else
            return track.name
        end
    end
end
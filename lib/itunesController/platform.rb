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

    class Platform

        def self.getUserHomeDir()
            homes = ["HOME", "HOMEPATH"]
            realHome = homes.detect {|h| ENV[h] != nil}
            if not realHome
                raise "Could not find home directory"
            end
            
            return ENV[realHome]
        end

        def self.isWindows()
            return RUBY_PLATFORM =~ /mswin|mingw/
        end

        def self.isMacOSX()
            return RUBY_PLATFORM =~ /darwin/
        end

        def self.isLinux()
            return RUBY_PLATFORM =~ /linux/
        end

        def self.isJRuby()
            return RUBY_PLATFORM =~ /java/
        end
    end
end


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

if RUBY_PLATFORM =~ /mswin|mingw/
  require 'windows_itunescontroller.rb'
elsif RUBY_PLATFORM =~ /darwin/
  require 'macosx_itunescontroller.rb'
else
  raise("Unsupported operating system #{RUBY_PLATFORM}.")
end

module ItunesController
    
    class ITunesControllerFactory
        
        # Used to create the iTunes controller for different platforms
        # @return [ItunesController::ITunesController] The itunes controller
        # @raise If the platform is unsupported
        def self.createController()
            if RUBY_PLATFORM =~ /mswin|mingw/
              return ItunesController::WindowsITunesController.new
            elsif RUBY_PLATFORM =~ /darwin/
              return ItunesController::MacOSXITunesController.new
            else
              raise("Unsupported operating system #{RUBY_PLATFORM}.")
            end            
        end
    end
end
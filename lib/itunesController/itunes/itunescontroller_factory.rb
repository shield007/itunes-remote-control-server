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

require 'itunesController/platform'
if ItunesController::Platform::isWindows()
  require 'itunesController/itunes/windows_itunescontroller.rb'
elsif ItunesController::Platform::isMacOSX()
  require 'itunesController/itunes/macosx_itunescontroller.rb'
else
  raise("Unsupported operating system #{RUBY_PLATFORM}.")
end

require 'itunesController/database/database'

module ItunesController
    
    # This is a factory class used to create a iTunes controller for the current platform
    class ITunesControllerFactory
        
        # Used to create the iTunes controller for different platforms
        # @return [ItunesController::BaseITunesController] The itunes controller
        # @raise If the platform is unsupported
        def self.createController()
            if ItunesController::Platform::isWindows()
              return ItunesController::WindowsITunesController.new()
            elsif ItunesController::Platform::isMacOSX()
              return ItunesController::MacOSXITunesController.new()
            else
              raise("Unsupported operating system #{RUBY_PLATFORM}.")
            end            
        end
    end
end

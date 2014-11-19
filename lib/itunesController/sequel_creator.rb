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

require 'itunesController/database/sequel_backend'
require 'itunesController/itunes/itunescontroller_factory'
require 'itunesController/controller_creator'

module ItunesController  

    class SequelControllerCreator < ControllerCreator    
        def createController(connnectionString)   
            dbBackend = ItunesController::SequelDatabaseBackend.new(connnectionString)
            return ItunesController::CachedController.new(ItunesController::ITunesControllerFactory::createController(),dbBackend)
        end
    end    
    
end
